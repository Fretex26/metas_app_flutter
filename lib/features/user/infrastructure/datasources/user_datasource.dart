import 'package:dio/dio.dart';
import 'package:metas_app/core/config/api_config.dart';
import 'package:metas_app/features/user/infrastructure/dto/user_response.dto.dart';

enum UserRole {
  user,
  sponsor,
  admin;

  String get value {
    switch (this) {
      case UserRole.user:
        return 'user';
      case UserRole.sponsor:
        return 'sponsor';
      case UserRole.admin:
        return 'admin';
    }
  }
}

class UserDatasource {
  final Dio _dio;

  UserDatasource({Dio? dio}) : _dio = dio ?? Dio();

  /// Registra un usuario en la API después del registro en Firebase
  /// 
  /// [firebaseIdToken] - Token ID de Firebase obtenido después del registro
  /// [name] - Nombre del usuario (requerido)
  /// [email] - Email del usuario (requerido, formato email válido)
  /// [role] - Rol del usuario (opcional, por defecto "user")
  /// [categoryIds] - Array de UUIDs de categorías (opcional)
  /// 
  /// Retorna [UserResponseDto] con los datos del usuario registrado
  /// 
  /// Lanza [DioException] en caso de error:
  /// - 409 Conflict: El email o Firebase UID ya está registrado
  /// - 401 Unauthorized: Token inválido o expirado
  /// - 400 Bad Request: Datos de entrada inválidos
  Future<UserResponseDto> registerUserInApi({
    required String firebaseIdToken,
    required String name,
    required String email,
    UserRole? role,
    List<String>? categoryIds,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/api/users',
        data: {
          'name': name,
          'email': email,
          if (role != null) 'role': role.value,
          if (categoryIds != null && categoryIds.isNotEmpty)
            'categoryIds': categoryIds,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $firebaseIdToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      return UserResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      // Re-lanzar la excepción para que el repositorio pueda manejarla
      rethrow;
    } catch (e) {
      throw Exception('Error inesperado al registrar usuario en la API: $e');
    }
  }
}
