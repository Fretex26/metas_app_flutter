import 'package:firebase_auth/firebase_auth.dart';
import 'package:metas_app/features/auth/domain/entities/app_user.dart';
import 'package:metas_app/features/auth/domain/repositories/auth.repository.dart';

class FirebaseAuthRepositoryImpl extends AuthRepository {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  
  @override
  Future<AppUser> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('User not found');
      }
      return AppUser(uid: user.uid, email: user.email ?? '');
    } catch (e) {
      throw Exception('Error getting current user: $e');
    }
  }

  @override
  Future<AppUser> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential user = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return AppUser(uid: user.user?.uid ?? '', email: user.user?.email ?? '');
    } catch (e) {
      throw Exception('Error signing in with email and password: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Error signing out: $e');
    }
  }

  @override
  Future<AppUser> signUp(String name, String email, String password) async {
    try {
      UserCredential user = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      return AppUser(uid: user.user?.uid ?? '', email: user.user?.email ?? '');
    } catch (e) {
      throw Exception('Error signing up: $e');
    }
  }

  @override
  Future<String> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return "Password reset email sent";
    } catch (e) {
      return "Error sending password reset email: $e";
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.delete();
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      throw Exception('Error deleting account: $e');
    }
  }
}