import 'package:dio/dio.dart';
import 'package:metas_app/features/user/domain/entities/user.dart';
import 'package:metas_app/features/user/domain/repositories/user.repository.dart';
import 'package:metas_app/features/user/infrastructure/datasources/user_datasource.dart';
import 'package:metas_app/features/user/infrastructure/dto/user_response.dto.dart';
import 'package:metas_app/features/user/infrastructure/mappers/user.mapper.dart';

class UserRepositoryImpl extends UserRepository {
  final UserDatasource _userDatasource;

  UserRepositoryImpl({UserDatasource? userDatasource})
      : _userDatasource = userDatasource ?? UserDatasource();

  @override
  Future<User> registerUser({
    required String firebaseIdToken,
    required String name,
    required String email,
    String? role,
    List<String>? categoryIds,
  }) async {
    try {
      UserRole? userRole;
      if (role != null) {
        switch (role.toLowerCase()) {
          case 'user':
            userRole = UserRole.user;
            break;
          case 'sponsor':
            userRole = UserRole.sponsor;
            break;
          case 'admin':
            userRole = UserRole.admin;
            break;
        }
      }

      final UserResponseDto dto = await _userDatasource.registerUserInApi(
        firebaseIdToken: firebaseIdToken,
        name: name,
        email: email,
        role: userRole,
        categoryIds: categoryIds,
      );

      return dto.toDomain();
    } on DioException {
      // Re-lanzar la excepción para que el servicio pueda manejarla
      rethrow;
    } catch (e) {
      throw Exception('Error al registrar usuario: $e');
    }
  }
}
