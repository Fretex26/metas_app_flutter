import 'package:metas_app/features/auth/domain/entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser?> getCurrentUser();
  Future<AppUser?> signInWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Future<AppUser?> signUp(String name, String email, String password);
  Future<String> sendPasswordResetEmail(String email);
  Future<void> deleteAccount();
}