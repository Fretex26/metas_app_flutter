import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:metas_app/core/config/api_config.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_review.dto.dart';
import 'package:metas_app/features/projects/infrastructure/dto/review_response.dto.dart';

/// Datasource para realizar operaciones HTTP relacionadas con reviews.
/// 
/// Implementa las llamadas a la API del backend usando Dio y maneja la autenticación
/// mediante tokens de Firebase. Todas las peticiones incluyen el header de autorización.
class ReviewDatasource {
  /// Cliente HTTP para realizar las peticiones
  final Dio _dio;

  /// Constructor del datasource
  /// 
  /// [dio] - Cliente Dio opcional para inyección de dependencias (útil para testing)
  ReviewDatasource({Dio? dio}) : _dio = dio ?? Dio();

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

  /// Crea una nueva review para un sprint.
  /// 
  /// Endpoint: POST /api/sprints/:sprintId/review
  /// 
  /// [sprintId] - Identificador único del sprint (UUID)
  /// [dto] - Datos de la review a crear
  /// 
  /// Retorna la review creada con su ID asignado y el porcentaje de progreso calculado.
  /// 
  /// Lanza una excepción si:
  /// - El sprint no existe o no pertenece al usuario (404)
  /// - Ya existe una review para este sprint (409)
  /// - Los datos son inválidos (400)
  /// - El usuario no está autenticado (401)
  Future<ReviewResponseDto> createReview(String sprintId, CreateReviewDto dto) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/api/sprints/$sprintId/review',
        data: dto.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return ReviewResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Sprint no encontrado o no pertenece al usuario');
      }
      if (e.response?.statusCode == 409) {
        throw Exception('Ya existe una review para este sprint');
      }
      if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data?['message'] ?? 'Error de validación';
        throw Exception(errorMessage);
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al crear review: $e');
    }
  }

  /// Obtiene la review asociada a un sprint específico.
  /// 
  /// Endpoint: GET /api/sprints/:sprintId/review
  /// 
  /// [sprintId] - Identificador único del sprint (UUID)
  /// 
  /// Retorna la review si existe y el usuario tiene permisos.
  /// 
  /// Lanza una excepción si:
  /// - El sprint no existe o no existe review para este sprint (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<ReviewResponseDto?> getSprintReview(String sprintId) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/sprints/$sprintId/review',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return ReviewResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 404) {
        // No existe review para este sprint, retornamos null
        return null;
      }
      if (e.response?.statusCode == 403) {
        throw Exception('No tienes permiso para acceder a este sprint');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al obtener review: $e');
    }
  }
}
