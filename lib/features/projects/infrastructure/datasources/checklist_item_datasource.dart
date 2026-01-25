import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:metas_app/core/config/api_config.dart';
import 'package:metas_app/features/projects/infrastructure/dto/checklist_item_response.dto.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_checklist_item.dto.dart';
import 'package:metas_app/features/projects/infrastructure/dto/update_checklist_item.dto.dart';

/// Datasource para realizar operaciones HTTP relacionadas con checklist items.
/// 
/// Implementa las llamadas a la API del backend usando Dio y maneja la autenticación
/// mediante tokens de Firebase. Todas las peticiones incluyen el header de autorización.
/// 
/// Nota: Al crear o actualizar un checklist item, el estado de la task se actualiza
/// automáticamente en el backend según las reglas de dependencias.
class ChecklistItemDatasource {
  /// Cliente HTTP para realizar las peticiones
  final Dio _dio;

  /// Constructor del datasource
  /// 
  /// [dio] - Cliente Dio opcional para inyección de dependencias (útil para testing)
  ChecklistItemDatasource({Dio? dio}) : _dio = dio ?? Dio();

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

  Future<List<ChecklistItemResponseDto>> getChecklistItems(String taskId) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/tasks/$taskId/checklist-items',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => ChecklistItemResponseDto.fromJson(json as Map<String, dynamic>)).toList();
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
      throw Exception('Error al obtener checklist items: $e');
    }
  }

  /// Obtiene un checklist item específico por su ID.
  /// 
  /// Endpoint: GET /api/tasks/:taskId/checklist-items/:id
  /// 
  /// [taskId] - Identificador único de la task (UUID)
  /// [id] - Identificador único del checklist item (UUID)
  /// 
  /// Retorna el checklist item si existe y el usuario tiene permisos.
  /// 
  /// Lanza una excepción si:
  /// - El checklist item no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<ChecklistItemResponseDto> getChecklistItemById(String taskId, String id) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/tasks/$taskId/checklist-items/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return ChecklistItemResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Checklist item no encontrado');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('No tienes permiso para acceder a este checklist item');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al obtener checklist item: $e');
    }
  }

  /// Crea un nuevo checklist item dentro de una task.
  /// 
  /// Endpoint: POST /api/tasks/:taskId/checklist-items
  /// 
  /// [taskId] - Identificador único de la task (UUID)
  /// [dto] - Datos del checklist item a crear
  /// 
  /// Retorna el checklist item creado con su ID asignado.
  /// 
  /// Nota: Al crear un checklist item, el estado de la task se actualiza automáticamente.
  /// 
  /// Lanza una excepción si:
  /// - La task no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<ChecklistItemResponseDto> createChecklistItem(String taskId, CreateChecklistItemDto dto) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/api/tasks/$taskId/checklist-items',
        data: dto.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return ChecklistItemResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Task no encontrada');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('No tienes permiso para crear checklist items en esta tarea');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al crear checklist item: $e');
    }
  }

  /// Actualiza un checklist item existente.
  /// 
  /// Endpoint: PUT /api/tasks/:taskId/checklist-items/:id
  /// 
  /// [taskId] - Identificador único de la task (UUID)
  /// [id] - Identificador único del checklist item (UUID)
  /// [dto] - Datos a actualizar (description, isRequired, isChecked)
  /// 
  /// Retorna el checklist item actualizado.
  /// 
  /// Nota: Al actualizar isChecked, el estado de la task se recalcula automáticamente.
  /// 
  /// Lanza una excepción si:
  /// - El checklist item no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<ChecklistItemResponseDto> updateChecklistItem(String taskId, String id, UpdateChecklistItemDto dto) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.put(
        '${ApiConfig.baseUrl}/api/tasks/$taskId/checklist-items/$id',
        data: dto.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return ChecklistItemResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Checklist item no encontrado');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('No tienes permiso para actualizar este checklist item');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al actualizar checklist item: $e');
    }
  }

  /// Elimina un checklist item existente.
  /// 
  /// Endpoint: DELETE /api/tasks/:taskId/checklist-items/:id
  /// 
  /// [taskId] - Identificador único de la task (UUID)
  /// [id] - Identificador único del checklist item (UUID)
  /// 
  /// Nota: Al eliminar un checklist item, el estado de la task se recalcula automáticamente.
  /// 
  /// Lanza una excepción si:
  /// - El checklist item no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<void> deleteChecklistItem(String taskId, String id) async {
    try {
      final token = await _getAuthToken();
      await _dio.delete(
        '${ApiConfig.baseUrl}/api/tasks/$taskId/checklist-items/$id',
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
        throw Exception('Checklist item no encontrado');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('No tienes permiso para eliminar este checklist item');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al eliminar checklist item: $e');
    }
  }
}
