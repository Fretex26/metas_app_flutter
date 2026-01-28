import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:metas_app/core/config/api_config.dart';
import 'package:metas_app/features/auth/infrastructure/dto/auth_me_response.dto.dart';

/// Datasource para [GET /api/auth/me].
///
/// Devuelve user + sponsor (si aplica) para redirección y control de acceso.
class AuthMeDatasource {
  final Dio _dio;

  AuthMeDatasource({Dio? dio}) : _dio = dio ?? Dio();

  Future<String> _getAuthToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    final token = await user.getIdToken();
    if (token == null) throw Exception('No se pudo obtener el token');
    return token;
  }

  /// Obtiene la sesión actual del usuario autenticado.
  ///
  /// Endpoint: GET /api/auth/me
  ///
  /// Retorna [AuthMeResponseDto] con datos del usuario y sponsor (si aplica).
  ///
  /// Lanza [DioException] si:
  /// - El usuario no está autenticado (401)
  /// - El usuario no existe en la base de datos (401)
  /// - Error de red o del servidor
  Future<AuthMeResponseDto> getAuthMe() async {
    final token = await _getAuthToken();
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/auth/me',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return AuthMeResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      // Re-lanzar con información adicional si es 401
      if (e.response?.statusCode == 401) {
        throw DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          type: e.type,
          error: 'Usuario no encontrado en el sistema',
        );
      }
      rethrow;
    }
  }
}
