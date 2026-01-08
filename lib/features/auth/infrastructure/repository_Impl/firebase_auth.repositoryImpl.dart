import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:metas_app/features/auth/domain/entities/app_user.dart';
import 'package:metas_app/features/auth/domain/repositories/auth.repository.dart';

class FirebaseAuthRepositoryImpl extends AuthRepository {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  
  // Instancia de GoogleSignIn configurada para siempre mostrar el selector de cuentas
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Fuerza la selección de cuenta en cada inicio de sesión
    // El sistema operativo manejará automáticamente biometría/2FA si está configurado
    scopes: ['email', 'profile'],
  );
  
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
    } on FirebaseAuthException {
      // Re-lanzar la excepción de Firebase para que el cubit pueda manejarla
      rethrow;
    } catch (e) {
      throw Exception('Error signing in with email and password: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Cerrar sesión en Firebase
      await _firebaseAuth.signOut();
      // Cerrar sesión en Google Sign In para asegurar que el próximo inicio muestre el selector
      await _googleSignIn.signOut();
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
    } on FirebaseAuthException {
      // Re-lanzar la excepción de Firebase para que el cubit pueda manejarla
      rethrow;
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

  @override
  Future<AppUser?> signInWithGoogle() async {
    try {
      // Cerrar sesión previa de Google para forzar siempre el selector de cuentas
      // Esto asegura que el usuario pueda elegir la cuenta en cada inicio de sesión
      await _googleSignIn.signOut();
      
      // Solicitar inicio de sesión - siempre mostrará el selector de cuentas
      // El sistema operativo manejará automáticamente la biometría/2FA si está disponible
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // Usuario canceló el proceso de inicio de sesión
        return null;
      }
      
      // Obtener las credenciales de autenticación
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Crear credencial para Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Iniciar sesión en Firebase con las credenciales de Google
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user == null || user.email == null || user.uid.isEmpty) {
        return null;
      }
      
      return AppUser(uid: user.uid, email: user.email!);
    } on FirebaseAuthException {
      // Re-lanzar la excepción de Firebase para que el cubit pueda manejarla
      rethrow;
    } catch (e) {
      throw Exception('Error signing in with Google: $e');
    }
  }
}