import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:metas_app/core/config/api_config.dart';
import 'package:metas_app/features/projects/infrastructure/dto/project_response.dto.dart';
import 'package:metas_app/features/projects/infrastructure/dto/milestone_response.dto.dart';
import 'package:metas_app/features/sponsored_goals/infrastructure/dto/category_response.dto.dart';
import 'package:metas_app/features/sponsored_goals/infrastructure/dto/create_sponsored_goal.dto.dart';
import 'package:metas_app/features/sponsored_goals/infrastructure/dto/sponsored_goal_response.dto.dart';
import 'package:metas_app/features/sponsored_goals/infrastructure/dto/sponsor_enrollment_response.dto.dart';
import 'package:metas_app/features/sponsored_goals/infrastructure/dto/update_enrollment_status.dto.dart';
import 'package:metas_app/features/sponsored_goals/infrastructure/dto/update_sponsored_goal.dto.dart';

/// Datasource para realizar operaciones HTTP relacionadas con Sponsored Goals.
/// 
/// Implementa las llamadas a la API del backend usando Dio y maneja la autenticación
/// mediante tokens de Firebase. Todas las peticiones incluyen el header de autorización.
/// 
/// Endpoints utilizados:
/// - POST /api/sponsored-goals (crear sponsored goal - solo sponsors)
/// - GET /api/sponsored-goals/available (listar disponibles - usuarios normales)
/// - POST /api/sponsored-goals/:id/enroll (inscribirse - usuarios normales)
/// - PATCH /api/sponsored-goals/enrollments/:enrollmentId/status (actualizar estado - sponsors)
/// - POST /api/sponsored-goals/milestones/:milestoneId/verify (verificar milestone - sponsors)
/// - GET /api/sponsored-goals/users/:email/projects (obtener proyectos de usuario - sponsors)
/// - GET /api/sponsored-goals/projects/:projectId/milestones (obtener milestones - sponsors)
class SponsoredGoalsDatasource {
  /// Cliente HTTP para realizar las peticiones
  final Dio _dio;

  /// Constructor del datasource
  /// 
  /// [dio] - Cliente Dio opcional para inyección de dependencias (útil para testing)
  SponsoredGoalsDatasource({Dio? dio}) : _dio = dio ?? Dio();

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

  /// Crea un nuevo Sponsored Goal (solo sponsors aprobados).
  /// 
  /// Endpoint: POST /api/sponsored-goals
  /// 
  /// [dto] - Datos del sponsored goal a crear
  /// 
  /// Retorna el sponsored goal creado con su ID asignado.
  /// 
  /// Lanza una excepción si:
  /// - El usuario no es sponsor aprobado (403)
  /// - El proyecto no pertenece al sponsor (400)
  /// - Los datos son inválidos (400)
  /// - El usuario no está autenticado (401)
  Future<SponsoredGoalResponseDto> createSponsoredGoal(
    CreateSponsoredGoalDto dto,
  ) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/api/sponsored-goals',
        data: dto.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return SponsoredGoalResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 403) {
        throw Exception(
          'Solo patrocinadores aprobados pueden crear objetivos patrocinados.',
        );
      }
      if (e.response?.statusCode == 400) {
        final msg = _extractErrorMessage(e.response?.data);
        throw Exception(msg);
      }
      if (e.response?.statusCode == 404) {
        throw Exception('No se encontró perfil de patrocinador');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al crear objetivo patrocinado: $e');
    }
  }

  static String _extractErrorMessage(dynamic data) {
    if (data == null) return 'Error de validación';
    if (data is Map) {
      final m = data as Map<String, dynamic>;
      if (m['message'] != null) return m['message'].toString();
      if (m['error'] != null) return m['error'].toString();
    }
    if (data is String) return data;
    return 'Error de validación';
  }

  /// Lista los Sponsored Goals del sponsor autenticado.
  /// 
  /// Endpoint: GET /api/sponsored-goals
  /// 
  /// Retorna los objetivos creados por el sponsor.
  /// 
  /// Lanza una excepción si:
  /// - El usuario no tiene perfil de sponsor (404)
  /// - El usuario no está autenticado (401)
  Future<List<SponsoredGoalResponseDto>> listSponsorSponsoredGoals() async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/sponsored-goals',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => SponsoredGoalResponseDto.fromJson(
                json as Map<String, dynamic>,
              ))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('No se encontró perfil de patrocinador');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al listar objetivos patrocinados: $e');
    }
  }

  /// Obtiene un Sponsored Goal por ID (solo si pertenece al sponsor).
  /// 
  /// Endpoint: GET /api/sponsored-goals/:id
  /// 
  /// Lanza una excepción si:
  /// - Objetivo no encontrado o sin perfil sponsor (404)
  /// - El objetivo no pertenece al sponsor (403)
  Future<SponsoredGoalResponseDto> getSponsoredGoalById(String id) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/sponsored-goals/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return SponsoredGoalResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 403) {
        throw Exception(
          'No tienes permiso para acceder a este objetivo patrocinado.',
        );
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Objetivo patrocinado no encontrado');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al obtener objetivo patrocinado: $e');
    }
  }

  /// Actualiza un Sponsored Goal (PATCH parcial). Solo el sponsor dueño.
  /// 
  /// Endpoint: PATCH /api/sponsored-goals/:id
  /// 
  /// Lanza una excepción si:
  /// - 404 objetivo o perfil, 403 no dueño, 400 validación
  Future<SponsoredGoalResponseDto> updateSponsoredGoal(
    String id,
    UpdateSponsoredGoalDto dto,
  ) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.patch(
        '${ApiConfig.baseUrl}/api/sponsored-goals/$id',
        data: dto.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return SponsoredGoalResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 403) {
        throw Exception(
          'No tienes permiso para actualizar este objetivo patrocinado.',
        );
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Objetivo patrocinado no encontrado');
      }
      if (e.response?.statusCode == 400) {
        final msg = _extractErrorMessage(e.response?.data);
        throw Exception(msg);
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al actualizar objetivo patrocinado: $e');
    }
  }

  /// Elimina un Sponsored Goal. Solo el sponsor dueño.
  /// 
  /// Endpoint: DELETE /api/sponsored-goals/:id
  /// 
  /// Respuesta: 204 No Content.
  /// 
  /// Lanza una excepción si:
  /// - 404 objetivo o perfil, 403 no dueño
  Future<void> deleteSponsoredGoal(String id) async {
    try {
      final token = await _getAuthToken();
      await _dio.delete(
        '${ApiConfig.baseUrl}/api/sponsored-goals/$id',
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
      if (e.response?.statusCode == 403) {
        throw Exception(
          'No tienes permiso para eliminar este objetivo patrocinado.',
        );
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Objetivo patrocinado no encontrado');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al eliminar objetivo patrocinado: $e');
    }
  }

  /// Lista los Sponsored Goals disponibles para usuarios normales.
  /// 
  /// Endpoint: GET /api/sponsored-goals/available?categoryIds=id1,id2
  /// 
  /// [categoryIds] - IDs de categorías opcionales para filtrar (separados por coma)
  /// 
  /// Retorna una lista de sponsored goals activos (fechas válidas y cupo disponible).
  /// 
  /// Lanza una excepción si:
  /// - El usuario no está autenticado (401)
  /// - Hay un error de red o del servidor
  Future<List<SponsoredGoalResponseDto>> getAvailableSponsoredGoals({
    List<String>? categoryIds,
  }) async {
    try {
      final token = await _getAuthToken();
      String url = '${ApiConfig.baseUrl}/api/sponsored-goals/available';
      if (categoryIds != null && categoryIds.isNotEmpty) {
        url += '?categoryIds=${categoryIds.join(',')}';
      }

      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => SponsoredGoalResponseDto.fromJson(
                json as Map<String, dynamic>,
              ))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al obtener objetivos disponibles: $e');
    }
  }

  /// Inscribe a un usuario normal a un Sponsored Goal.
  /// 
  /// Endpoint: POST /api/sponsored-goals/:id/enroll
  /// 
  /// [sponsoredGoalId] - Identificador único del sponsored goal (UUID)
  /// 
  /// Retorna la inscripción creada. Automáticamente se duplica el proyecto
  /// en los proyectos del usuario.
  /// 
  /// Lanza una excepción si:
  /// - El sponsored goal no existe (404)
  /// - El usuario ya está inscrito (409)
  /// - Se alcanzó el número máximo de usuarios (400)
  /// - El usuario no está autenticado (401)
  Future<SponsorEnrollmentResponseDto> enrollInSponsoredGoal(
    String sponsoredGoalId,
  ) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/api/sponsored-goals/$sponsoredGoalId/enroll',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return SponsorEnrollmentResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Objetivo patrocinado no encontrado');
      }
      if (e.response?.statusCode == 409) {
        throw Exception('Ya estás inscrito en este objetivo');
      }
      if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data?['message'] ?? 'Error de validación';
        throw Exception(errorMessage);
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al inscribirse al objetivo: $e');
    }
  }

  /// Actualiza el estado de una inscripción (solo sponsors).
  /// 
  /// Endpoint: PATCH /api/sponsored-goals/enrollments/:enrollmentId/status
  /// 
  /// [enrollmentId] - Identificador único de la inscripción (UUID)
  /// [dto] - DTO con el nuevo estado
  /// 
  /// Retorna la inscripción actualizada.
  /// 
  /// Lanza una excepción si:
  /// - El enrollment no existe (404)
  /// - El usuario no es sponsor (403)
  /// - El usuario no está autenticado (401)
  Future<SponsorEnrollmentResponseDto> updateEnrollmentStatus(
    String enrollmentId,
    UpdateEnrollmentStatusDto dto,
  ) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.patch(
        '${ApiConfig.baseUrl}/api/sponsored-goals/enrollments/$enrollmentId/status',
        data: dto.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return SponsorEnrollmentResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('Solo patrocinadores pueden actualizar inscripciones');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Inscripción no encontrada');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al actualizar estado de inscripción: $e');
    }
  }

  /// Verifica una milestone de un proyecto patrocinado (solo sponsors).
  /// 
  /// Endpoint: POST /api/sponsored-goals/milestones/:milestoneId/verify
  /// 
  /// [milestoneId] - Identificador único de la milestone (UUID)
  /// 
  /// Retorna la milestone verificada con status "completed".
  /// 
  /// Lanza una excepción si:
  /// - La milestone no existe (404)
  /// - El usuario no es sponsor (403)
  /// - El proyecto no es patrocinado (400)
  /// - El método de verificación no es MANUAL (400)
  /// - El usuario no está autenticado (401)
  Future<MilestoneResponseDto> verifyMilestone(String milestoneId) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/api/sponsored-goals/milestones/$milestoneId/verify',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return MilestoneResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('Solo patrocinadores pueden verificar milestones');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Milestone no encontrada');
      }
      if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data?['message'] ?? 'Error de validación';
        throw Exception(errorMessage);
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al verificar milestone: $e');
    }
  }

  /// Obtiene los proyectos patrocinados de un usuario (solo sponsors).
  /// 
  /// Endpoint: GET /api/sponsored-goals/users/:email/projects
  /// 
  /// [userEmail] - Email del usuario del cual obtener los proyectos
  /// 
  /// Retorna una lista de proyectos patrocinados del usuario que pertenecen
  /// a los sponsored goals del sponsor que hace la petición.
  /// 
  /// Lanza una excepción si:
  /// - El usuario no es sponsor (403)
  /// - El usuario no está autenticado (401)
  /// - Hay un error de red o del servidor
  Future<List<ProjectResponseDto>> getUserSponsoredProjects(
    String userEmail,
  ) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/sponsored-goals/users/$userEmail/projects',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => ProjectResponseDto.fromJson(
                json as Map<String, dynamic>,
              ))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('Solo patrocinadores pueden ver proyectos de usuarios');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al obtener proyectos del usuario: $e');
    }
  }

  /// Obtiene todas las categorías disponibles.
  /// 
  /// Endpoint: GET /api/categories
  /// 
  /// Retorna una lista de todas las categorías del catálogo.
  /// 
  /// Lanza una excepción si:
  /// - El usuario no está autenticado (401)
  /// - Hay un error de red o del servidor
  Future<List<CategoryResponseDto>> getCategories() async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/categories',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => CategoryResponseDto.fromJson(
                json as Map<String, dynamic>,
              ))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al obtener categorías: $e');
    }
  }

  /// Obtiene las milestones de un proyecto patrocinado (solo sponsors).
  /// 
  /// Endpoint: GET /api/sponsored-goals/projects/:projectId/milestones
  /// 
  /// [projectId] - Identificador único del proyecto patrocinado (UUID)
  /// 
  /// Retorna una lista de milestones del proyecto patrocinado.
  /// 
  /// Lanza una excepción si:
  /// - El proyecto no existe (404)
  /// - El usuario no es sponsor (403)
  /// - El proyecto no es patrocinado (400)
  /// - El usuario no está autenticado (401)
  Future<List<MilestoneResponseDto>> getProjectMilestones(
    String projectId,
  ) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/sponsored-goals/projects/$projectId/milestones',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => MilestoneResponseDto.fromJson(
                json as Map<String, dynamic>,
              ))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 403) {
        throw Exception(
          'Solo patrocinadores pueden ver milestones de proyectos patrocinados',
        );
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Proyecto no encontrado');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al obtener milestones del proyecto: $e');
    }
  }
}
