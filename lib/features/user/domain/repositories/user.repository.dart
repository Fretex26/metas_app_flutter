import 'package:metas_app/features/user/domain/entities/user.dart';

abstract class UserRepository {
  /// Registra un usuario en la API después del registro en Firebase
  /// 
  /// [firebaseIdToken] - Token ID de Firebase obtenido después del registro
  /// [name] - Nombre del usuario (requerido)
  /// [email] - Email del usuario (requerido, formato email válido)
  /// [role] - Rol del usuario (opcional)
  /// [categoryIds] - Array de UUIDs de categorías (opcional)
  /// 
  /// Retorna [User] con los datos del usuario registrado
  Future<User> registerUser({
    required String firebaseIdToken,
    required String name,
    required String email,
    String? role,
    List<String>? categoryIds,
  });
}
