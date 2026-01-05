import 'package:metas_app/features/domain/entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> getCurrentUser();
  Future<AppUser> signInWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Future<AppUser> signUp(String email, String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> deleteAccount();
}