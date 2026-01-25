import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:metas_app/core/config/api_config.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_milestone.dto.dart';
import 'package:metas_app/features/projects/infrastructure/dto/milestone_response.dto.dart';
import 'package:metas_app/features/projects/infrastructure/dto/update_milestone.dto.dart';

/// Datasource para realizar operaciones HTTP relacionadas con milestones.
/// 
/// Implementa las llamadas a la API del backend usando Dio y maneja la autenticación
/// mediante tokens de Firebase. Todas las peticiones incluyen el header de autorización.
class MilestoneDatasource {
  /// Cliente HTTP para realizar las peticiones
  final Dio _dio;

  /// Constructor del datasource
  /// 
  /// [dio] - Cliente Dio opcional para inyección de dependencias (útil para testing)
  MilestoneDatasource({Dio? dio}) : _dio = dio ?? Dio();

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

  Future<List<MilestoneResponseDto>> getProjectMilestones(String projectId) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/projects/$projectId/milestones',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => MilestoneResponseDto.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Proyecto no encontrado');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al obtener milestones: $e');
    }
  }

  /// Obtiene un milestone específico por su ID.
  /// 
  /// Endpoint: GET /api/projects/:projectId/milestones/:milestoneId
  /// 
  /// [projectId] - Identificador único del proyecto (UUID)
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// 
  /// Retorna el milestone si existe y el usuario tiene permisos.
  /// 
  /// Lanza una excepción si:
  /// - El milestone no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<MilestoneResponseDto> getMilestoneById(String projectId, String milestoneId) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/projects/$projectId/milestones/$milestoneId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return MilestoneResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Milestone no encontrado');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('No tienes permiso para acceder a este milestone');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al obtener milestone: $e');
    }
  }

  /// Crea un nuevo milestone dentro de un proyecto.
  /// 
  /// Endpoint: POST /api/projects/:projectId/milestones
  /// 
  /// [projectId] - Identificador único del proyecto (UUID)
  /// [dto] - Datos del milestone a crear, incluyendo recompensa opcional
  /// 
  /// Retorna el milestone creado con su ID asignado.
  /// 
  /// Lanza una excepción si:
  /// - El proyecto no existe o no pertenece al usuario (404)
  /// - Los datos son inválidos (400)
  /// - El usuario no está autenticado (401)
  Future<MilestoneResponseDto> createMilestone(String projectId, CreateMilestoneDto dto) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/api/projects/$projectId/milestones',
        data: dto.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return MilestoneResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Proyecto no encontrado');
      }
      if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data?['message'] ?? 'Error de validación';
        throw Exception(errorMessage);
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al crear milestone: $e');
    }
  }

  /// Actualiza un milestone existente.
  /// 
  /// Endpoint: PUT /api/projects/:projectId/milestones/:id
  /// 
  /// [projectId] - Identificador único del proyecto (UUID)
  /// [id] - Identificador único del milestone (UUID)
  /// [dto] - Datos a actualizar (solo name y description)
  /// 
  /// Retorna el milestone actualizado.
  /// 
  /// Nota: Solo se pueden actualizar name y description. El estado se actualiza
  /// automáticamente según las tasks.
  /// 
  /// Lanza una excepción si:
  /// - El milestone no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - Los datos son inválidos (400)
  /// - El usuario no está autenticado (401)
  Future<MilestoneResponseDto> updateMilestone(
    String projectId,
    String id,
    UpdateMilestoneDto dto,
  ) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.put(
        '${ApiConfig.baseUrl}/api/projects/$projectId/milestones/$id',
        data: dto.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return MilestoneResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Milestone no encontrado');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('No tienes permiso para modificar este milestone');
      }
      if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data?['message'] ?? 'Error de validación';
        throw Exception(errorMessage);
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al actualizar milestone: $e');
    }
  }

  /// Elimina un milestone existente.
  /// 
  /// Endpoint: DELETE /api/projects/:projectId/milestones/:id
  /// 
  /// [projectId] - Identificador único del proyecto (UUID)
  /// [id] - Identificador único del milestone (UUID)
  /// 
  /// Nota: El backend elimina automáticamente en cascada todos los sprints,
  /// tasks, checklist items y datos relacionados.
  /// 
  /// Lanza una excepción si:
  /// - El milestone no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<void> deleteMilestone(String projectId, String id) async {
    try {
      final token = await _getAuthToken();
      await _dio.delete(
        '${ApiConfig.baseUrl}/api/projects/$projectId/milestones/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Milestone no encontrado');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('No tienes permiso para eliminar este milestone');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al eliminar milestone: $e');
    }
  }
}
