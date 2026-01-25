import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:metas_app/core/config/api_config.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_task.dto.dart';
import 'package:metas_app/features/projects/infrastructure/dto/task_response.dto.dart';
import 'package:metas_app/features/projects/infrastructure/dto/update_task.dto.dart';

/// Datasource para realizar operaciones HTTP relacionadas con tasks.
/// 
/// Implementa las llamadas a la API del backend usando Dio y maneja la autenticación
/// mediante tokens de Firebase. Todas las peticiones incluyen el header de autorización.
class TaskDatasource {
  /// Cliente HTTP para realizar las peticiones
  final Dio _dio;

  /// Constructor del datasource
  /// 
  /// [dio] - Cliente Dio opcional para inyección de dependencias (útil para testing)
  TaskDatasource({Dio? dio}) : _dio = dio ?? Dio();

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

  Future<List<TaskResponseDto>> getMilestoneTasks(String milestoneId) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/milestone/$milestoneId/task',
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
        throw Exception('Milestone no encontrado');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al obtener tasks: $e');
    }
  }

  /// Obtiene una task específica por su ID.
  /// 
  /// Endpoint: GET /api/milestone/:milestoneId/task/:taskId
  /// 
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// [taskId] - Identificador único de la task (UUID)
  /// 
  /// Retorna la task si existe y el usuario tiene permisos.
  /// 
  /// Lanza una excepción si:
  /// - La task no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<TaskResponseDto> getTaskById(String milestoneId, String taskId) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/milestone/$milestoneId/task/$taskId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return TaskResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Task no encontrada');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('No tienes permiso para acceder a esta task');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al obtener task: $e');
    }
  }

  /// Crea una nueva task dentro de un milestone.
  /// 
  /// Endpoint: POST /api/milestone/:milestoneId/task
  /// 
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// [dto] - Datos de la task a crear, incluyendo fechas y recursos
  /// 
  /// Retorna la task creada con su ID asignado.
  /// 
  /// Lanza una excepción si:
  /// - El milestone o sprint no existe (404)
  /// - El período de la task excede el del sprint (400)
  /// - Las fechas son inválidas (400)
  /// - El usuario no está autenticado (401)
  Future<TaskResponseDto> createTask(String milestoneId, CreateTaskDto dto) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/api/milestone/$milestoneId/task',
        data: dto.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return TaskResponseDto.fromJson(response.data as Map<String, dynamic>);
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
      throw Exception('Error al crear task: $e');
    }
  }

  /// Actualiza una task existente.
  /// 
  /// Endpoint: PUT /api/milestone/:milestoneId/task/:id
  /// 
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// [id] - Identificador único de la task (UUID)
  /// [dto] - Datos a actualizar (name, description, fechas, recursos, puntos)
  /// 
  /// Retorna la task actualizada.
  /// 
  /// Nota: Solo se pueden actualizar name, description, startDate, endDate,
  /// resourcesAvailable, resourcesNeeded e incentivePoints. El estado se actualiza
  /// automáticamente según los checklist items. Si se actualizan las fechas, se valida
  /// que startDate sea anterior a endDate y que no excedan el período del sprint.
  /// 
  /// Lanza una excepción si:
  /// - La task no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - Los datos son inválidos (400)
  /// - El usuario no está autenticado (401)
  Future<TaskResponseDto> updateTask(
    String milestoneId,
    String id,
    UpdateTaskDto dto,
  ) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.put(
        '${ApiConfig.baseUrl}/api/milestone/$milestoneId/task/$id',
        data: dto.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return TaskResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Task no encontrada');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('No tienes permiso para modificar esta task');
      }
      if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data?['message'] ?? 'Error de validación';
        throw Exception(errorMessage);
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al actualizar task: $e');
    }
  }

  /// Elimina una task existente.
  /// 
  /// Endpoint: DELETE /api/milestone/:milestoneId/task/:id
  /// 
  /// [milestoneId] - Identificador único del milestone (UUID)
  /// [id] - Identificador único de la task (UUID)
  /// 
  /// Nota: El backend elimina automáticamente en cascada todos los checklist items
  /// y daily entries relacionados.
  /// 
  /// Lanza una excepción si:
  /// - La task no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<void> deleteTask(String milestoneId, String id) async {
    try {
      final token = await _getAuthToken();
      await _dio.delete(
        '${ApiConfig.baseUrl}/api/milestone/$milestoneId/task/$id',
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
        throw Exception('Task no encontrada');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('No tienes permiso para eliminar esta task');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al eliminar task: $e');
    }
  }
}
