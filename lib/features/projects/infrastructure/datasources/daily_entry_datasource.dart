import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:metas_app/core/config/api_config.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_daily_entry.dto.dart';
import 'package:metas_app/features/projects/infrastructure/dto/daily_entry_response.dto.dart';

/// Datasource para realizar operaciones HTTP relacionadas con entradas diarias.
/// 
/// Implementa las llamadas a la API del backend usando Dio y maneja la autenticación
/// mediante tokens de Firebase. Todas las peticiones incluyen el header de autorización.
class DailyEntryDatasource {
  /// Cliente HTTP para realizar las peticiones
  final Dio _dio;

  /// Constructor del datasource
  /// 
  /// [dio] - Cliente Dio opcional para inyección de dependencias (útil para testing)
  DailyEntryDatasource({Dio? dio}) : _dio = dio ?? Dio();

  /// Obtiene el token de autenticación de Firebase del usuario actual.
  /// 
  /// Retorna el token ID de Firebase necesario para autenticar las peticiones.
  /// 
  /// Lanza una excepción si:
  /// - El usuario no está autenticado
  /// - No se puede obtener el token
  Future<String> _getAuthToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }
    final token = await user.getIdToken();
    if (token == null) {
      throw Exception('No se pudo obtener el token de autenticación');
    }
    return token;
  }

  /// Crea una nueva entrada diaria.
  /// 
  /// Endpoint: POST /api/daily-entries
  /// 
  /// [dto] - Datos de la entrada diaria a crear
  /// 
  /// Retorna la entrada diaria creada con su ID asignado.
  /// 
  /// Lanza una excepción si:
  /// - Los datos son inválidos (400)
  /// - El usuario no está autenticado (401)
  /// - Ya existe una entrada diaria para el día de hoy (409)
  /// - Error del servidor (500)
  Future<DailyEntryResponseDto> createDailyEntry(
    CreateDailyEntryDto dto,
  ) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/api/daily-entries',
        data: dto.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          // Permitir que códigos 4xx y 5xx pasen sin lanzar excepción automáticamente
          // para poder manejarlos manualmente
          validateStatus: (status) {
            return status != null && status < 600;
          },
        ),
      );

      // Manejar respuesta exitosa
      if (response.statusCode == 201) {
        return DailyEntryResponseDto.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      
      // Manejar errores HTTP manualmente
      if (response.statusCode == 409) {
        // Extraer el mensaje del backend
        String errorMessage = 'Ya existe una entrada diaria para hoy en este sprint. Solo se permite una por día y sprint.';
        
        try {
          final responseData = response.data;
          if (responseData != null) {
            if (responseData is Map<String, dynamic>) {
              // Intentar obtener el mensaje de diferentes campos posibles
              errorMessage = responseData['message'] ?? 
                           responseData['error'] ?? 
                           responseData['msg'] ?? 
                           errorMessage;
            } else if (responseData is String) {
              errorMessage = responseData;
            }
          }
        } catch (_) {
          // Si hay error al extraer el mensaje, usar el mensaje por defecto
        }
        
        throw Exception(errorMessage);
      }
      
      if (response.statusCode == 400) {
        final responseData = response.data;
        String errorMessage = 'Error de validación';
        
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message'] ?? errorMessage;
        } else if (responseData is String) {
          errorMessage = responseData;
        }
        
        throw Exception(errorMessage);
      }
      
      if (response.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      
      // Otros códigos de error
      throw Exception('Error al crear entrada diaria: Código de estado ${response.statusCode}');
    } on DioException catch (e) {
      // Manejar errores específicos por código de estado
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        
        if (statusCode == 401) {
          throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
        }
        
        if (statusCode == 400) {
          // Intentar extraer el mensaje del backend
          final responseData = e.response!.data;
          String errorMessage = 'Error de validación';
          
          if (responseData is Map<String, dynamic>) {
            errorMessage = responseData['message'] ?? errorMessage;
          } else if (responseData is String) {
            errorMessage = responseData;
          }
          
          throw Exception(errorMessage);
        }
        
        if (statusCode == 409) {
          // Intentar extraer el mensaje del backend para el error 409
          final responseData = e.response!.data;
          String errorMessage = 'Ya existe una entrada diaria para hoy en este sprint. Solo se permite una por día y sprint.';
          
          if (responseData is Map<String, dynamic>) {
            errorMessage = responseData['message'] ?? errorMessage;
          } else if (responseData is String) {
            errorMessage = responseData;
          }
          
          throw Exception(errorMessage);
        }
      }
      
      // Manejar errores de conexión
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Error de conexión. Verifica tu internet.');
      }
      
      // Si es otra DioException, relanzarla con un mensaje más descriptivo
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        throw Exception('Error al crear entrada diaria: Código de estado $statusCode');
      }
      
      rethrow;
    } catch (e) {
      // Si ya es una Exception con un mensaje descriptivo, relanzarla
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error al crear entrada diaria: $e');
    }
  }

  /// Obtiene todas las entradas diarias del usuario autenticado.
  /// 
  /// Endpoint: GET /api/daily-entries
  /// 
  /// Retorna una lista de entradas diarias ordenadas por fecha de creación descendente
  /// (más recientes primero).
  /// 
  /// Lanza una excepción si:
  /// - El usuario no está autenticado (401)
  /// - Error del servidor (500)
  Future<List<DailyEntryResponseDto>> getUserDailyEntries() async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/daily-entries',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => DailyEntryResponseDto.fromJson(
                  json as Map<String, dynamic>,
                ))
            .toList();
      } else {
        throw Exception('Error al obtener entradas diarias: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Error de conexión. Verifica tu internet.');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al obtener entradas diarias: $e');
    }
  }

  /// Obtiene la entrada diaria del usuario para una fecha y un sprint concretos.
  ///
  /// Endpoint: GET /api/daily-entries/date/:date?sprintId=:sprintId
  ///
  /// [date] - Fecha en formato DateTime (se formatea como YYYY-MM-DD).
  /// [sprintId] - UUID del sprint (obligatorio). Cada daily entry pertenece a un sprint.
  ///
  /// Retorna la entrada diaria si existe para esa fecha en ese sprint, o null si no existe
  /// (el backend responde 404 cuando no hay entrada para esa fecha en el sprint).
  ///
  /// Lanza una excepción si:
  /// - sprintId ausente o no válido (400)
  /// - Formato de fecha inválido (400)
  /// - El usuario no está autenticado (401)
  /// - Error del servidor (500)
  Future<DailyEntryResponseDto?> getDailyEntryByDate(
    DateTime date,
    String sprintId,
  ) async {
    try {
      final token = await _getAuthToken();
      final dateString =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/daily-entries/date/$dateString',
        queryParameters: {'sprintId': sprintId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );

      if (response.statusCode == 200) {
        final body = response.data;
        if (body == null || body is! Map<String, dynamic>) {
          return null;
        }
        return DailyEntryResponseDto.fromJson(body);
      }
      if (response.statusCode == 404) {
        return null;
      }
      if (response.statusCode == 400) {
        throw Exception('Formato de fecha o sprintId inválido');
      }
      throw Exception('Error al obtener entrada diaria: ${response.statusCode}');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 400) {
        throw Exception('Formato de fecha o sprintId inválido');
      }
      if (e.response?.statusCode == 404) {
        return null;
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Error de conexión. Verifica tu internet.');
      }
      rethrow;
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error al obtener entrada diaria por fecha: $e');
    }
  }
}
