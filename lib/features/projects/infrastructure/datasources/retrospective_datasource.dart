import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:metas_app/core/config/api_config.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_retrospective.dto.dart';
import 'package:metas_app/features/projects/infrastructure/dto/retrospective_response.dto.dart';

/// Datasource para realizar operaciones HTTP relacionadas con retrospectivas.
/// 
/// Implementa las llamadas a la API del backend usando Dio y maneja la autenticación
/// mediante tokens de Firebase. Todas las peticiones incluyen el header de autorización.
class RetrospectiveDatasource {
  /// Cliente HTTP para realizar las peticiones
  final Dio _dio;

  /// Constructor del datasource
  /// 
  /// [dio] - Cliente Dio opcional para inyección de dependencias (útil para testing)
  RetrospectiveDatasource({Dio? dio}) : _dio = dio ?? Dio();

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

  /// Crea una nueva retrospectiva para un sprint.
  /// 
  /// Endpoint: POST /api/sprints/:sprintId/retrospective
  /// 
  /// [sprintId] - Identificador único del sprint (UUID)
  /// [dto] - Datos de la retrospectiva a crear
  /// 
  /// Retorna la retrospectiva creada con su ID asignado.
  /// 
  /// Lanza una excepción si:
  /// - El sprint no existe o no pertenece al usuario (404)
  /// - Ya existe una retrospectiva para este sprint (409)
  /// - Los datos son inválidos (400)
  /// - El usuario no está autenticado (401)
  Future<RetrospectiveResponseDto> createRetrospective(
    String sprintId,
    CreateRetrospectiveDto dto,
  ) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/api/sprints/$sprintId/retrospective',
        data: dto.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return RetrospectiveResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Sprint no encontrado o no pertenece al usuario');
      }
      if (e.response?.statusCode == 409) {
        throw Exception('Ya existe una retrospectiva para este sprint');
      }
      if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data?['message'] ?? 'Error de validación';
        throw Exception(errorMessage);
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al crear retrospectiva: $e');
    }
  }

  /// Obtiene la retrospectiva asociada a un sprint específico.
  /// 
  /// Endpoint: GET /api/sprints/:sprintId/retrospective
  /// 
  /// [sprintId] - Identificador único del sprint (UUID)
  /// 
  /// Retorna la retrospectiva si existe y el usuario tiene permisos.
  /// Si es pública, cualquiera puede verla. Si es privada, solo el dueño puede verla.
  /// 
  /// Lanza una excepción si:
  /// - El sprint no existe o no existe retrospectiva para este sprint (404)
  /// - El usuario no tiene permisos (403) - solo aplica si es privada y no eres el dueño
  /// - El usuario no está autenticado (401)
  Future<RetrospectiveResponseDto?> getSprintRetrospective(String sprintId) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/sprints/$sprintId/retrospective',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return RetrospectiveResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 404) {
        // No existe retrospectiva para este sprint, retornamos null
        return null;
      }
      if (e.response?.statusCode == 403) {
        throw Exception('No tienes permiso para acceder a esta retrospectiva');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al obtener retrospectiva: $e');
    }
  }

  /// Obtiene todas las retrospectivas públicas disponibles.
  /// 
  /// Endpoint: GET /api/retrospectives/public
  /// 
  /// Retorna una lista de retrospectivas marcadas como públicas.
  /// 
  /// Lanza una excepción si:
  /// - El usuario no está autenticado (401)
  Future<List<RetrospectiveResponseDto>> getPublicRetrospectives() async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/retrospectives/public',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => RetrospectiveResponseDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al obtener retrospectivas públicas: $e');
    }
  }
}
