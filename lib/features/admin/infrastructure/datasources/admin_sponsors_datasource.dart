import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:metas_app/core/config/api_config.dart';
import 'package:metas_app/features/admin/infrastructure/dto/admin_sponsor_response.dto.dart';

/// Datasource para operaciones HTTP de administración de sponsors.
///
/// Implementa las llamadas a la API del backend usando Dio y maneja la autenticación
/// mediante tokens de Firebase. Todas las peticiones requieren rol **admin**.
///
/// Endpoints utilizados:
/// - GET /api/admin/sponsors/pending
/// - GET /api/admin/sponsors
/// - GET /api/admin/sponsors/:id
/// - POST /api/admin/sponsors/:id/approve
/// - POST /api/admin/sponsors/:id/reject
/// - POST /api/admin/sponsors/:id/disable
/// - POST /api/admin/sponsors/:id/enable
class AdminSponsorsDatasource {
  final Dio _dio;

  /// Constructor del datasource.
  ///
  /// [dio] - Cliente Dio opcional para inyección de dependencias (útil para testing).
  AdminSponsorsDatasource({Dio? dio}) : _dio = dio ?? Dio();

  /// Obtiene el token de autenticación de Firebase del usuario actual.
  ///
  /// Retorna el token ID de Firebase necesario para autenticar las peticiones.
  ///
  /// Lanza una excepción si:
  /// - El usuario no está autenticado
  /// - No se puede obtener el token
  Future<String> _getAuthToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    final token = await user.getIdToken();
    if (token == null) throw Exception('No se pudo obtener el token');
    return token;
  }

  /// Obtiene la lista de sponsors pendientes de aprobación.
  ///
  /// Endpoint: GET /api/admin/sponsors/pending
  ///
  /// Retorna una lista de sponsors con estado **PENDING**.
  ///
  /// Lanza una excepción si:
  /// - El usuario no está autenticado (401)
  /// - El usuario no tiene rol admin (403)
  /// - Error de red o del servidor
  Future<List<AdminSponsorResponseDto>> getPending() async {
    var token = await _getAuthToken();
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/admin/sponsors/pending',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((e) => AdminSponsorResponseDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Intentar refrescar el token y reintentar una vez
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final refreshedToken = await user.getIdToken(true); // Forzar refresh
            if (refreshedToken != null) {
              try {
                final retryResponse = await _dio.get(
                  '${ApiConfig.baseUrl}/api/admin/sponsors/pending',
                  options: Options(
                    headers: {
                      'Authorization': 'Bearer $refreshedToken',
                      'Content-Type': 'application/json',
                    },
                  ),
                );
                final List<dynamic> data = retryResponse.data as List<dynamic>;
                return data
                    .map((e) => AdminSponsorResponseDto.fromJson(e as Map<String, dynamic>))
                    .toList();
              } on DioException {
                // Re-lanzar el error del reintento
                rethrow;
              }
            }
          }
        } catch (retryError) {
          // Si el refresh falla, continuar con el error original
        }
        throw Exception(
          'Tu sesión ha expirado o no tienes acceso. Por favor, cierra sesión e inicia sesión nuevamente.',
        );
      }
      if (e.response?.statusCode == 403) {
        throw Exception(
          'No tienes permisos para acceder a esta sección. '
          'Contacta al administrador del sistema si crees que esto es un error.',
        );
      }
      rethrow;
    }
  }

  /// Obtiene la lista de todos los sponsors (opcionalmente filtrada por estado).
  ///
  /// Endpoint: GET /api/admin/sponsors?status=...
  ///
  /// [status] - Filtro opcional: `pending` | `approved` | `rejected` | `disabled`.
  /// Si es `null`, retorna todos los sponsors sin filtrar.
  ///
  /// Retorna una lista de sponsors según el filtro aplicado.
  ///
  /// Lanza una excepción si:
  /// - El usuario no está autenticado (401)
  /// - El usuario no tiene rol admin (403)
  /// - Error de red o del servidor
  Future<List<AdminSponsorResponseDto>> getAll({String? status}) async {
    final token = await _getAuthToken();
    final query = status != null ? '?status=$status' : '';
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/admin/sponsors$query',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((e) => AdminSponsorResponseDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception(
          'No tienes permisos para acceder a esta sección. '
          'Contacta al administrador del sistema si crees que esto es un error.',
        );
      }
      rethrow;
    }
  }

  /// Obtiene el detalle de un sponsor específico.
  ///
  /// Endpoint: GET /api/admin/sponsors/:sponsorId
  ///
  /// [sponsorId] - Identificador único del sponsor (UUID).
  ///
  /// Retorna el sponsor con todos sus datos, incluyendo información del usuario asociado.
  ///
  /// Lanza una excepción si:
  /// - El usuario no está autenticado (401)
  /// - El usuario no tiene rol admin (403)
  /// - El sponsor no existe (404)
  /// - Error de red o del servidor
  Future<AdminSponsorResponseDto> getById(String sponsorId) async {
    final token = await _getAuthToken();
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/admin/sponsors/$sponsorId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return AdminSponsorResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception(
          'No tienes permisos para acceder a esta sección. '
          'Contacta al administrador del sistema si crees que esto es un error.',
        );
      }
      rethrow;
    }
  }

  /// Aprueba un sponsor (cambia estado de PENDING a APPROVED).
  ///
  /// Endpoint: POST /api/admin/sponsors/:sponsorId/approve
  ///
  /// [sponsorId] - Identificador único del sponsor a aprobar.
  ///
  /// Solo funciona si el sponsor está en estado **PENDING**.
  /// Una vez aprobado, el sponsor puede usar el portal sponsor.
  ///
  /// Lanza una excepción si:
  /// - El usuario no está autenticado (401)
  /// - El usuario no tiene rol admin (403)
  /// - El sponsor no está en estado PENDING (400)
  /// - El sponsor no existe (404)
  /// - Error de red o del servidor
  Future<void> approve(String sponsorId) async {
    final token = await _getAuthToken();
    try {
      await _dio.post(
        '${ApiConfig.baseUrl}/api/admin/sponsors/$sponsorId/approve',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception(
          'No tienes permisos para realizar esta acción. '
          'Contacta al administrador del sistema si crees que esto es un error.',
        );
      }
      rethrow;
    }
  }

  /// Rechaza un sponsor (cambia estado de PENDING a REJECTED).
  ///
  /// Endpoint: POST /api/admin/sponsors/:sponsorId/reject
  ///
  /// [sponsorId] - Identificador único del sponsor a rechazar.
  /// [rejectionReason] - Motivo del rechazo (opcional).
  ///
  /// Solo funciona si el sponsor está en estado **PENDING**.
  /// Una vez rechazado, el sponsor **no puede acceder** a la aplicación.
  ///
  /// Lanza una excepción si:
  /// - El usuario no está autenticado (401)
  /// - El usuario no tiene rol admin (403)
  /// - El sponsor no está en estado PENDING (400)
  /// - El sponsor no existe (404)
  /// - Error de red o del servidor
  Future<void> reject(String sponsorId, {String? rejectionReason}) async {
    final token = await _getAuthToken();
    try {
      await _dio.post(
        '${ApiConfig.baseUrl}/api/admin/sponsors/$sponsorId/reject',
        data: rejectionReason != null
            ? <String, dynamic>{'rejectionReason': rejectionReason}
            : null,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception(
          'No tienes permisos para realizar esta acción. '
          'Contacta al administrador del sistema si crees que esto es un error.',
        );
      }
      rethrow;
    }
  }

  /// Deshabilita un sponsor (cambia estado de APPROVED a DISABLED).
  ///
  /// Endpoint: POST /api/admin/sponsors/:sponsorId/disable
  ///
  /// [sponsorId] - Identificador único del sponsor a deshabilitar.
  ///
  /// Solo funciona si el sponsor está en estado **APPROVED**.
  /// Una vez deshabilitado, el sponsor **pierde acceso** inmediatamente.
  ///
  /// Lanza una excepción si:
  /// - El usuario no está autenticado (401)
  /// - El usuario no tiene rol admin (403)
  /// - El sponsor no está en estado APPROVED (400)
  /// - El sponsor no existe (404)
  /// - Error de red o del servidor
  Future<void> disable(String sponsorId) async {
    final token = await _getAuthToken();
    try {
      await _dio.post(
        '${ApiConfig.baseUrl}/api/admin/sponsors/$sponsorId/disable',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception(
          'No tienes permisos para realizar esta acción. '
          'Contacta al administrador del sistema si crees que esto es un error.',
        );
      }
      rethrow;
    }
  }

  /// Habilita un sponsor (cambia estado de DISABLED a APPROVED).
  ///
  /// Endpoint: POST /api/admin/sponsors/:sponsorId/enable
  ///
  /// [sponsorId] - Identificador único del sponsor a habilitar.
  ///
  /// Solo funciona si el sponsor está en estado **DISABLED**.
  /// Una vez habilitado, el sponsor **recupera acceso** al portal sponsor.
  ///
  /// Lanza una excepción si:
  /// - El usuario no está autenticado (401)
  /// - El usuario no tiene rol admin (403)
  /// - El sponsor no está en estado DISABLED (400)
  /// - El sponsor no existe (404)
  /// - Error de red o del servidor
  Future<void> enable(String sponsorId) async {
    final token = await _getAuthToken();
    try {
      await _dio.post(
        '${ApiConfig.baseUrl}/api/admin/sponsors/$sponsorId/enable',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception(
          'No tienes permisos para realizar esta acción. '
          'Contacta al administrador del sistema si crees que esto es un error.',
        );
      }
      rethrow;
    }
  }
}
