import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:metas_app/core/config/api_config.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_sprint.dto.dart';
import 'package:metas_app/features/projects/infrastructure/dto/sprint_response.dto.dart';
import 'package:metas_app/features/projects/infrastructure/dto/task_response.dto.dart';
import 'package:metas_app/features/projects/infrastructure/dto/update_sprint.dto.dart';

/// Datasource para realizar operaciones HTTP relacionadas con sprints.
/// 
/// Implementa las llamadas a la API del backend usando Dio y maneja la autenticación
/// mediante tokens de Firebase. Todas las peticiones incluyen el header de autorización.
class SprintDatasource {
  /// Cliente HTTP para realizar las peticiones
  final Dio _dio;

  /// Constructor del datasource
  /// 
  /// [dio] - Cliente Dio opcional para inyección de dependencias (útil para testing)
  SprintDatasource({Dio? dio}) : _dio = dio ?? Dio();

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

  /// Obtiene todos los sprints de un milestone específico.
  /// 
  /// Endpoint: GET /api/milestones/:milestoneId/sprints
  /// 
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// 
  /// Retorna una lista de sprints asociados al milestone.
  /// 
  /// Lanza una excepción si:
  /// - El milestone no existe (404)
  /// - El usuario no está autenticado (401)
  Future<List<SprintResponseDto>> getMilestoneSprints(String milestoneId) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/milestones/$milestoneId/sprints',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => SprintResponseDto.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Milestone no encontrado');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al obtener sprints: $e');
    }
  }

  /// Obtiene un sprint específico por su ID.
  /// 
  /// Endpoint: GET /api/milestones/:milestoneId/sprints/:id
  /// 
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// [sprintId] - Identificador único del sprint (UUID)
  /// 
  /// Retorna el sprint si existe y el usuario tiene permisos.
  /// 
  /// Lanza una excepción si:
  /// - El sprint no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<SprintResponseDto> getSprintById(String milestoneId, String sprintId) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/milestones/$milestoneId/sprints/$sprintId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return SprintResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Sprint no encontrado');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('No tienes permiso para acceder a este sprint');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al obtener sprint: $e');
    }
  }

  /// Crea un nuevo sprint dentro de un milestone.
  /// 
  /// Endpoint: POST /api/milestones/:milestoneId/sprints
  /// 
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// [dto] - Datos del sprint a crear
  /// 
  /// Retorna el sprint creado con su ID asignado.
  /// 
  /// Lanza una excepción si:
  /// - El milestone no existe o no pertenece al usuario (404)
  /// - Los datos son inválidos (400) - período > 28 días, fechas inválidas
  /// - El usuario no está autenticado (401)
  Future<SprintResponseDto> createSprint(String milestoneId, CreateSprintDto dto) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/api/milestones/$milestoneId/sprints',
        data: dto.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return SprintResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Milestone no encontrado');
      }
      if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data?['message'] ?? 'Error de validación';
        throw Exception(errorMessage);
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al crear sprint: $e');
    }
  }

  /// Actualiza un sprint existente.
  /// 
  /// Endpoint: PUT /api/milestones/:milestoneId/sprints/:id
  /// 
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// [sprintId] - Identificador único del sprint (UUID)
  /// [dto] - Datos a actualizar (todos los campos son opcionales)
  /// 
  /// Retorna el sprint actualizado.
  /// 
  /// Lanza una excepción si:
  /// - El sprint no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - Los datos son inválidos (400) - período > 28 días, fechas inválidas
  /// - El usuario no está autenticado (401)
  Future<SprintResponseDto> updateSprint(
    String milestoneId,
    String sprintId,
    UpdateSprintDto dto,
  ) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.put(
        '${ApiConfig.baseUrl}/api/milestones/$milestoneId/sprints/$sprintId',
        data: dto.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return SprintResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Sprint no encontrado');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('No tienes permiso para modificar este sprint');
      }
      if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data?['message'] ?? 'Error de validación';
        throw Exception(errorMessage);
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al actualizar sprint: $e');
    }
  }

  /// Elimina un sprint existente.
  /// 
  /// Endpoint: DELETE /api/milestones/:milestoneId/sprints/:id
  /// 
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// [sprintId] - Identificador único del sprint (UUID)
  /// 
  /// Nota: El backend elimina automáticamente en cascada:
  /// - Review asociada (si existe, relación 1:1)
  /// - Retrospective asociada (si existe, relación 1:1)
  /// - DailyEntries relacionados
  /// - Las tasks NO se eliminan, solo quedan con sprintId = null
  /// 
  /// Lanza una excepción si:
  /// - El sprint no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<void> deleteSprint(String milestoneId, String sprintId) async {
    try {
      final token = await _getAuthToken();
      await _dio.delete(
        '${ApiConfig.baseUrl}/api/milestones/$milestoneId/sprints/$sprintId',
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
        throw Exception('Sprint no encontrado');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('No tienes permiso para eliminar este sprint');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al eliminar sprint: $e');
    }
  }

  /// Obtiene todas las tasks de un sprint específico.
  /// 
  /// Endpoint: GET /api/milestones/:milestoneId/sprints/:id/tasks
  /// 
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// [sprintId] - Identificador único del sprint (UUID)
  /// 
  /// Retorna una lista de tasks asociadas al sprint.
  /// 
  /// Lanza una excepción si:
  /// - El sprint no existe (404)
  /// - El usuario no está autenticado (401)
  Future<List<TaskResponseDto>> getSprintTasks(String milestoneId, String sprintId) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/milestones/$milestoneId/sprints/$sprintId/tasks',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => TaskResponseDto.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Sprint no encontrado');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al obtener tasks del sprint: $e');
    }
  }
}
