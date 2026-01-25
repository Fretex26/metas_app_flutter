import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:metas_app/core/config/api_config.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_project.dto.dart';
import 'package:metas_app/features/projects/infrastructure/dto/project_progress.dto.dart';
import 'package:metas_app/features/projects/infrastructure/dto/project_response.dto.dart';
import 'package:metas_app/features/projects/infrastructure/dto/update_project.dto.dart';

/// Datasource para realizar operaciones HTTP relacionadas con proyectos.
/// 
/// Implementa las llamadas a la API del backend usando Dio y maneja la autenticación
/// mediante tokens de Firebase. Todas las peticiones incluyen el header de autorización.
class ProjectDatasource {
  /// Cliente HTTP para realizar las peticiones
  final Dio _dio;

  /// Constructor del datasource
  /// 
  /// [dio] - Cliente Dio opcional para inyección de dependencias (útil para testing)
  ProjectDatasource({Dio? dio}) : _dio = dio ?? Dio();

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

  /// Obtiene todos los proyectos del usuario autenticado.
  /// 
  /// Endpoint: GET /api/projects
  /// 
  /// Retorna una lista de proyectos asociados al usuario actual.
  /// 
  /// Lanza una excepción si:
  /// - El usuario no está autenticado (401)
  /// - Hay un error de red o del servidor
  Future<List<ProjectResponseDto>> getUserProjects() async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/projects',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => ProjectResponseDto.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al obtener proyectos: $e');
    }
  }

  /// Obtiene un proyecto específico por su ID.
  /// 
  /// Endpoint: GET /api/projects/:id
  /// 
  /// [id] - Identificador único del proyecto (UUID)
  /// 
  /// Retorna el proyecto si existe y el usuario tiene permisos.
  /// 
  /// Lanza una excepción si:
  /// - El proyecto no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<ProjectResponseDto> getProjectById(String id) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/projects/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return ProjectResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Proyecto no encontrado');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('No tienes permiso para acceder a este proyecto');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al obtener proyecto: $e');
    }
  }

  /// Obtiene el progreso calculado de un proyecto.
  /// 
  /// Endpoint: GET /api/projects/:id/progress
  /// 
  /// [id] - Identificador único del proyecto (UUID)
  /// 
  /// Retorna el progreso basado en tasks completadas vs total de tasks.
  /// 
  /// Lanza una excepción si:
  /// - El proyecto no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<ProjectProgressDto> getProjectProgress(String id) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/projects/$id/progress',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return ProjectProgressDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Proyecto no encontrado');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('No tienes permiso para acceder a este proyecto');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al obtener progreso del proyecto: $e');
    }
  }

  /// Crea un nuevo proyecto para el usuario autenticado.
  /// 
  /// Endpoint: POST /api/projects
  /// 
  /// [dto] - Datos del proyecto a crear, incluyendo la recompensa obligatoria
  /// 
  /// Retorna el proyecto creado con su ID asignado.
  /// 
  /// Lanza una excepción si:
  /// - El usuario ya tiene 6 proyectos activos (400)
  /// - Los datos son inválidos (400)
  /// - El usuario no está autenticado (401)
  Future<ProjectResponseDto> createProject(CreateProjectDto dto) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/api/projects',
        data: dto.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return ProjectResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data?['message'] ?? 'Error de validación';
        throw Exception(errorMessage);
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al crear proyecto: $e');
    }
  }

  /// Actualiza un proyecto existente.
  /// 
  /// Endpoint: PUT /api/projects/:id
  /// 
  /// [id] - Identificador único del proyecto (UUID)
  /// [dto] - Datos a actualizar (solo los campos que se quieren cambiar)
  /// 
  /// Retorna el proyecto actualizado.
  /// 
  /// Nota: Solo se pueden actualizar name, description, purpose, budget, finalDate,
  /// resourcesAvailable y resourcesNeeded. El estado se actualiza automáticamente.
  /// 
  /// Lanza una excepción si:
  /// - El proyecto no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - Los datos son inválidos (400)
  /// - El usuario no está autenticado (401)
  Future<ProjectResponseDto> updateProject(String id, UpdateProjectDto dto) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.put(
        '${ApiConfig.baseUrl}/api/projects/$id',
        data: dto.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return ProjectResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Proyecto no encontrado');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('No tienes permiso para modificar este proyecto');
      }
      if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data?['message'] ?? 'Error de validación';
        throw Exception(errorMessage);
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al actualizar proyecto: $e');
    }
  }

  /// Obtiene un proyecto por su rewardId.
  /// 
  /// Busca entre todos los proyectos del usuario el que tiene el rewardId especificado.
  /// 
  /// [rewardId] - Identificador único de la reward (UUID)
  /// 
  /// Retorna el proyecto si existe y el usuario tiene permisos.
  /// Retorna null si no se encuentra ningún proyecto con ese rewardId.
  /// 
  /// Lanza una excepción si:
  /// - El usuario no está autenticado (401)
  /// - Hay un error de red o del servidor
  Future<ProjectResponseDto?> getProjectByRewardId(String rewardId) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/projects',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final List<dynamic> data = response.data as List<dynamic>;
      final projects = data.map((json) => ProjectResponseDto.fromJson(json as Map<String, dynamic>)).toList();
      
      // Buscar el proyecto que tiene el rewardId especificado
      for (final project in projects) {
        if (project.rewardId == rewardId) {
          return project;
        }
      }
      
      // No se encontró ningún proyecto con ese rewardId
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al obtener proyecto por rewardId: $e');
    }
  }

  /// Elimina un proyecto existente.
  /// 
  /// Endpoint: DELETE /api/projects/:id
  /// 
  /// [id] - Identificador único del proyecto (UUID)
  /// 
  /// Nota: El backend elimina automáticamente en cascada todos los milestones,
  /// sprints, tasks, checklist items y datos relacionados.
  /// 
  /// Lanza una excepción si:
  /// - El proyecto no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<void> deleteProject(String id) async {
    try {
      final token = await _getAuthToken();
      await _dio.delete(
        '${ApiConfig.baseUrl}/api/projects/$id',
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
        throw Exception('Proyecto no encontrado');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('No tienes permiso para eliminar este proyecto');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al eliminar proyecto: $e');
    }
  }
}
