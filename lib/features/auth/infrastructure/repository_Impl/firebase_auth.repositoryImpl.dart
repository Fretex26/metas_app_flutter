import 'package:firebase_auth/firebase_auth.dart';
import 'package:metas_app/features/auth/domain/entities/app_user.dart';
import 'package:metas_app/features/auth/domain/repositories/auth.repository.dart';

class FirebaseAuthRepositoryImpl extends AuthRepository {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  
  @override
  Future<AppUser?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return null;
      }
      
      // Recargar el usuario desde el servidor para verificar que aún existe
      try {
        await user.reload();
        // Obtener el usuario actualizado después del reload
        final updatedUser = _firebaseAuth.currentUser;
        if (updatedUser == null || updatedUser.email == null || updatedUser.uid.isEmpty) {
          // Si el usuario fue eliminado, hacer signOut para limpiar el estado local
          await _firebaseAuth.signOut();
          return null;
        }
        return AppUser(uid: updatedUser.uid, email: updatedUser.email!);
      } on FirebaseAuthException catch (e) {
        // Si el usuario fue eliminado o el token es inválido, hacer signOut
        if (e.code == 'user-not-found' || e.code == 'user-disabled' || e.code == 'invalid-user-token') {
          await _firebaseAuth.signOut();
          return null;
        }
        rethrow;
      }
    } catch (e) {
      // En caso de cualquier otro error, hacer signOut para limpiar el estado
      try {
        await _firebaseAuth.signOut();
      } catch (_) {
        // Ignorar errores al hacer signOut
      }
      return null;
    }
  }

  @override
  Future<AppUser?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;
      if (user == null || user.email == null || user.uid.isEmpty) {
        return null;
      }
      return AppUser(uid: user.uid, email: user.email!);
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
  Future<AppUser?> signUp(String name, String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;
      if (user == null || user.email == null || user.uid.isEmpty) {
        return null;
      }
      return AppUser(uid: user.uid, email: user.email!);
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