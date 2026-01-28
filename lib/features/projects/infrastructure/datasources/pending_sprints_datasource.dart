import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:metas_app/core/config/api_config.dart';
import 'package:metas_app/features/projects/infrastructure/dto/pending_sprint_response.dto.dart';

/// Datasource para realizar operaciones HTTP relacionadas con sprints pendientes.
/// 
/// Implementa las llamadas a la API del backend usando Dio y maneja la autenticación
/// mediante tokens de Firebase. Todas las peticiones incluyen el header de autorización.
class PendingSprintsDatasource {
  /// Cliente HTTP para realizar las peticiones
  final Dio _dio;

  /// Constructor del datasource
  /// 
  /// [dio] - Cliente Dio opcional para inyección de dependencias (útil para testing)
  PendingSprintsDatasource({Dio? dio}) : _dio = dio ?? Dio();

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

  /// Obtiene todos los sprints pendientes de review o retrospectiva.
  /// 
  /// Endpoint: GET /api/reviews/pending-sprints
  /// 
  /// Retorna una lista de sprints que han finalizado y que necesitan review o retrospectiva.
  /// 
  /// Lanza una excepción si:
  /// - El usuario no está autenticado (401)
  /// - La ruta no existe en el servidor (404)
  /// - Error del servidor (500)
  Future<List<PendingSprintResponseDto>> getPendingSprints() async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/reviews/pending-sprints',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => PendingSprintResponseDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('La ruta no está disponible en el servidor. Por favor, verifica que el endpoint esté implementado.');
      }
      if (e.response?.statusCode == 500) {
        throw Exception('Error del servidor. Por favor, intenta más tarde.');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Error de conexión. Verifica tu internet.');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al obtener sprints pendientes: $e');
    }
  }
}
