import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:metas_app/features/auth/domain/entities/app_user.dart';
import 'package:metas_app/features/auth/domain/repositories/auth.repository.dart';
import 'package:metas_app/features/user/domain/repositories/user.repository.dart';
import 'package:metas_app/features/user/infrastructure/repositories_impl/user.repository_impl.dart';

class FirebaseAuthRepositoryImpl extends AuthRepository {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final UserRepository _userRepository;
  
  FirebaseAuthRepositoryImpl({UserRepository? userRepository})
      : _userRepository = userRepository ?? UserRepositoryImpl();
  
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
  Future<AppUser?> signUp(String name, String email, String password, String role) async {
    try {
      // 1. Registrar en Firebase
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;
      if (user == null || user.email == null || user.uid.isEmpty) {
        return null;
      }

      // 2. Obtener el token ID de Firebase
      String? token = await user.getIdToken();
      if (token == null) {
        throw Exception('No se pudo obtener el token de Firebase');
      }

      // 3. Registrar en la API
      try {
        await _userRepository.registerUser(
          firebaseIdToken: token,
          name: name,
          email: email,
          role: role,
        );
      } on DioException catch (e) {
        // Manejar errores de la API
        if (e.response?.statusCode == 409) {
          // El usuario ya está registrado en la API (puede ser un re-registro)
          // Continuar normalmente ya que el usuario de Firebase se creó correctamente
        } else if (e.response?.statusCode == 401) {
          // Token inválido, intentar obtener uno nuevo
          token = await user.getIdToken(true); // Forzar refresh del token
          if (token != null) {
            try {
              await _userRepository.registerUser(
                firebaseIdToken: token,
                name: name,
                email: email,
                role: role,
              );
            } catch (retryError) {
              // Si aún falla después del reintento, eliminar el usuario de Firebase
              // para evitar estado inconsistente (usuario en Firebase pero no en BD)
              try {
                await user.delete();
              } catch (_) {
                // Ignorar errores al eliminar
              }
              // Re-lanzar la excepción para que el cubit la maneje
              throw Exception(
                'No se pudo registrar el usuario en el sistema. '
                'Por favor, intenta nuevamente. Si el problema persiste, contacta al soporte.',
              );
            }
          } else {
            // No se pudo obtener token refrescado, eliminar usuario de Firebase
            try {
              await user.delete();
            } catch (_) {
              // Ignorar errores al eliminar
            }
            throw Exception('No se pudo obtener un token válido. Por favor, intenta nuevamente.');
          }
        } else {
          // Otros errores de la API: eliminar usuario de Firebase para evitar estado inconsistente
          try {
            await user.delete();
          } catch (_) {
            // Ignorar errores al eliminar
          }
          // Re-lanzar la excepción con mensaje amigable
          final errorMessage = e.response?.data?['message']?.toString() ?? 
              'No se pudo completar el registro. Por favor, intenta nuevamente.';
          throw Exception(errorMessage);
        }
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
      // Resetear el flag de usuario nuevo
      _lastGoogleUserIsNew = false;
      
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
      
      // Verificar si el usuario es nuevo usando additionalUserInfo
      _lastGoogleUserIsNew = userCredential.additionalUserInfo?.isNewUser ?? false;
      
      return AppUser(uid: user.uid, email: user.email!);
    } on FirebaseAuthException {
      // Re-lanzar la excepción de Firebase para que el cubit pueda manejarla
      rethrow;
    } catch (e) {
      throw Exception('Error signing in with Google: $e');
    }
  }
  
  // Variable temporal para almacenar si el último usuario autenticado con Google es nuevo
  bool _lastGoogleUserIsNew = false;
  
  @override
  bool get lastGoogleUserIsNew => _lastGoogleUserIsNew;
  
  // Método para completar el registro después de autenticarse con Google
  @override
  Future<AppUser?> completeGoogleRegistration(String name, String role) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      final email = user.email;
      if (email == null || email.isEmpty) {
        throw Exception('El usuario no tiene un email válido');
      }
      
      // Actualizar el perfil del usuario con el nombre
      await user.updateDisplayName(name);
      await user.reload();
      
      final updatedUser = _firebaseAuth.currentUser;
      if (updatedUser == null || updatedUser.email == null || updatedUser.uid.isEmpty) {
        return null;
      }

      // Obtener el token ID de Firebase
      String? token = await updatedUser.getIdToken();
      if (token == null) {
        throw Exception('No se pudo obtener el token de Firebase');
      }

      // Registrar en la API
      try {
        await _userRepository.registerUser(
          firebaseIdToken: token,
          name: name,
          email: email,
          role: role,
        );
      } on DioException catch (e) {
        // Manejar errores de la API
        if (e.response?.statusCode == 409) {
          // El usuario ya está registrado en la API (puede ser un re-registro)
          // Continuar normalmente ya que el usuario de Firebase se creó correctamente
        } else if (e.response?.statusCode == 401) {
          // Token inválido, intentar obtener uno nuevo
          token = await updatedUser.getIdToken(true); // Forzar refresh del token
          if (token != null) {
            try {
              await _userRepository.registerUser(
                firebaseIdToken: token,
                name: name,
                email: email,
                role: role,
              );
            } catch (retryError) {
              // Si aún falla después del reintento, eliminar el usuario de Firebase
              try {
                await updatedUser.delete();
              } catch (_) {
                // Ignorar errores al eliminar
              }
              // Re-lanzar la excepción para que el cubit la maneje
              throw Exception(
                'No se pudo registrar el usuario en el sistema. '
                'Por favor, intenta nuevamente. Si el problema persiste, contacta al soporte.',
              );
            }
          } else {
            // No se pudo obtener token refrescado, eliminar usuario de Firebase
            try {
              await updatedUser.delete();
            } catch (_) {
              // Ignorar errores al eliminar
            }
            throw Exception('No se pudo obtener un token válido. Por favor, intenta nuevamente.');
          }
        } else {
          // Otros errores de la API: eliminar usuario de Firebase para evitar estado inconsistente
          try {
            await updatedUser.delete();
          } catch (_) {
            // Ignorar errores al eliminar
          }
          // Re-lanzar la excepción con mensaje amigable
          final errorMessage = e.response?.data?['message']?.toString() ?? 
              'No se pudo completar el registro. Por favor, intenta nuevamente.';
          throw Exception(errorMessage);
        }
      }
      
      return AppUser(uid: updatedUser.uid, email: updatedUser.email!);
    } catch (e) {
      throw Exception('Error completando el registro: $e');
    }
  }
}