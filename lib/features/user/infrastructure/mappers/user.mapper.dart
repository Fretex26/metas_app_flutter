import 'package:metas_app/features/user/domain/entities/user.dart';
import 'package:metas_app/features/user/infrastructure/dto/user_response.dto.dart';

extension UserResponseDtoMapper on UserResponseDto {
  User toDomain() {
    return User(
      id: id,
      name: name,
      email: email,
      role: role,
      createdAt: createdAt,
      updatedAt: updatedAt,
      categories: categories,
    );
  }
}
