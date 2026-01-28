import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/application/use_cases/get_auth_me.use_case.dart';
import 'package:metas_app/features/auth/domain/entities/app_user.dart';
import 'package:metas_app/features/auth/domain/entities/auth_me_session.dart';
import 'package:metas_app/features/auth/domain/repositories/auth.repository.dart';
import 'package:metas_app/features/auth/presentation/cubits/auth.states.dart';
import 'package:metas_app/features/sponsor/application/use_cases/create_sponsor.use_case.dart';
import 'package:metas_app/features/sponsor/infrastructure/dto/create_sponsor.dto.dart';

/// Cubit para gestionar la autenticación y sesión del usuario.
///
/// Maneja:
/// - Verificación de estado de autenticación al iniciar la app
/// - Login con email/password y Google
/// - Registro de usuarios (normales y sponsors)
/// - Obtención de sesión (user + sponsor) para redirección
/// - Creación de perfil sponsor durante el registro
/// - Logout
///
/// Tras login/registro exitoso, obtiene la sesión completa mediante [GetAuthMeUseCase]
/// y emite [AuthSuccess] con [AuthMeSession] para que el router redirija según rol y estado.
class AuthCubit extends Cubit<AuthStates> {
  final AuthRepository authRepository;
  final GetAuthMeUseCase getAuthMeUseCase;
  final CreateSponsorUseCase createSponsorUseCase;

  /// Constructor del cubit.
  ///
  /// Requiere:
  /// - [authRepository]: Repositorio para operaciones de Firebase Auth
  /// - [getAuthMeUseCase]: Use case para obtener sesión completa (user + sponsor)
  /// - [createSponsorUseCase]: Use case para crear perfil sponsor durante registro
  AuthCubit({
    required this.authRepository,
    required this.getAuthMeUseCase,
    required this.createSponsorUseCase,
  }) : super(AuthInitial());

  /// Obtiene el usuario actual (compatibilidad con código existente).
  ///
  /// Retorna [AppUser] si hay sesión activa, `null` en caso contrario.
  /// Nota: Preferir usar [session] para acceso a datos completos (rol, sponsor, etc.).
  AppUser? get currentUser {
    final s = state;
    if (s is AuthSuccess) {
      final u = s.user;
      return AppUser(uid: u.id, email: u.email);
    }
    return null;
  }

  /// Obtiene la sesión actual del usuario autenticado.
  ///
  /// Retorna [AuthMeSession] con datos del usuario y sponsor (si aplica) si hay sesión activa,
  /// `null` en caso contrario.
  ///
  /// Usado para:
  /// - Verificar rol del usuario (user | sponsor | admin)
  /// - Verificar estado del sponsor (pending | approved | rejected | disabled)
  /// - Redirección post-login
  AuthMeSession? get session {
    final s = state;
    if (s is AuthSuccess) return s.session;
    return null;
  }

  /// Verifica el estado de autenticación al iniciar la app.
  ///
  /// Si hay un usuario autenticado en Firebase, obtiene su sesión completa
  /// mediante [getAuthMeUseCase] y emite [AuthSuccess].
  /// Si no hay usuario, emite [Unauthenticated].
  ///
  /// **Manejo de errores:**
  /// - Si el usuario existe en Firebase pero no en la BD (401), hace logout
  ///   y emite [Unauthenticated] para que el usuario se registre nuevamente.
  /// - Si hay otros errores, emite [AuthFailure] con el mensaje correspondiente.
  ///
  /// Se llama automáticamente al inicializar el cubit en [main.dart].
  void checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final appUser = await authRepository.getCurrentUser();
      if (appUser == null) {
        emit(Unauthenticated());
        return;
      }
      final session = await getAuthMeUseCase();
      emit(AuthSuccess(session: session));
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Usuario existe en Firebase pero no en la BD (registro incompleto)
        // Hacer logout para limpiar el estado y permitir registro nuevamente
        try {
          await authRepository.signOut();
        } catch (_) {
          // Ignorar errores al hacer logout
        }
        emit(Unauthenticated());
        return;
      }
      emit(AuthFailure(error: e.response?.data?['message']?.toString() ?? e.message ?? 'Error al obtener sesión'));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  /// Inicia sesión con email y contraseña.
  ///
  /// [email] - Email del usuario
  /// [password] - Contraseña del usuario
  ///
  /// Tras login exitoso, obtiene la sesión completa y emite [AuthSuccess].
  /// El router redirigirá según el rol y estado del sponsor.
  ///
  /// Emite:
  /// - [AuthLoading] mientras procesa
  /// - [AuthSuccess] con sesión completa si el login es exitoso
  /// - [Unauthenticated] si no hay usuario o credenciales inválidas
  /// - [AuthFailure] si ocurre un error
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    emit(AuthLoading());
    try {
      final appUser = await authRepository.signInWithEmailAndPassword(email, password);
      if (appUser == null) {
        emit(Unauthenticated());
        return;
      }
      final session = await getAuthMeUseCase();
      emit(AuthSuccess(session: session));
    } on FirebaseAuthException catch (e) {
      final errorMessage = _getErrorMessage(e.code);
      emit(AuthFailure(error: errorMessage));
      emit(Unauthenticated());
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        emit(Unauthenticated());
        return;
      }
      emit(AuthFailure(error: e.response?.data?['message']?.toString() ?? e.message ?? 'Error al obtener sesión'));
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthFailure(error: 'Ocurrió un error inesperado. Por favor, intenta de nuevo.'));
      emit(Unauthenticated());
    }
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No existe una cuenta con este correo electrónico.';
      case 'wrong-password':
        return 'La contraseña es incorrecta.';
      case 'invalid-email':
        return 'El formato del correo electrónico no es válido.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada. Contacta con el soporte.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Por favor, intenta más tarde.';
      case 'operation-not-allowed':
        return 'Esta operación no está permitida.';
      case 'email-already-in-use':
        return 'Este correo electrónico ya está registrado.';
      case 'weak-password':
        return 'La contraseña es demasiado débil. Debe tener al menos 6 caracteres.';
      case 'invalid-credential':
        return 'Las credenciales son inválidas. Verifica tu correo y contraseña.';
      case 'invalid-verification-code':
        return 'El código de verificación no es válido.';
      case 'invalid-verification-id':
        return 'El ID de verificación no es válido.';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu conexión a internet.';
      default:
        return 'Error de autenticación: $errorCode';
    }
  }

  /// Registra un nuevo usuario.
  ///
  /// [name] - Nombre del usuario
  /// [email] - Email del usuario
  /// [password] - Contraseña del usuario
  /// [role] - Rol del usuario: `user` o `sponsor`
  /// [sponsorData] - Datos del sponsor (solo si [role] es `sponsor`)
  ///
  /// Flujo:
  /// 1. Crea usuario en Firebase Auth
  /// 2. Registra usuario en API (POST /api/users) con el rol especificado
  /// 3. Si [role] es `sponsor` y [sponsorData] no es null, crea perfil sponsor (POST /api/sponsors)
  /// 4. Obtiene sesión completa mediante [getAuthMeUseCase]
  /// 5. Emite [AuthSuccess] con la sesión
  ///
  /// El router redirigirá según el rol:
  /// - `user` → Portal usuario normal
  /// - `sponsor` → Pantalla de espera (PENDING) o portal sponsor (APPROVED)
  ///
  /// Emite:
  /// - [AuthLoading] mientras procesa
  /// - [AuthSuccess] con sesión completa si el registro es exitoso
  /// - [Unauthenticated] si falla
  /// - [AuthFailure] si ocurre un error
  Future<void> signUp(
    String name,
    String email,
    String password,
    String role, {
    CreateSponsorDto? sponsorData,
  }) async {
    emit(AuthLoading());
    try {
      final appUser = await authRepository.signUp(name, email, password, role);
      if (appUser == null) {
        emit(Unauthenticated());
        return;
      }
      if (role == 'sponsor' && sponsorData != null) {
        await createSponsorUseCase(sponsorData);
      }
      final session = await getAuthMeUseCase();
      emit(AuthSuccess(session: session));
    } on FirebaseAuthException catch (e) {
      final errorMessage = _getErrorMessage(e.code);
      emit(AuthFailure(error: errorMessage));
      emit(Unauthenticated());
    } on DioException catch (e) {
      // Si falla al crear sponsor, el usuario ya está en Firebase y API
      // Hacer logout para limpiar estado y permitir reintento
      if (role == 'sponsor' && sponsorData != null) {
        try {
          await authRepository.signOut();
        } catch (_) {
          // Ignorar errores al hacer logout
        }
        emit(AuthFailure(
          error: e.response?.data?['message']?.toString() ?? 
              'No se pudo crear el perfil de patrocinador. Por favor, intenta nuevamente.',
        ));
        emit(Unauthenticated());
        return;
      }
      emit(AuthFailure(error: e.response?.data?['message']?.toString() ?? e.message ?? 'Error'));
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
      emit(Unauthenticated());
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    try {
      await authRepository.signOut();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<String> sendPasswordResetEmail(String email) async {
    emit(AuthLoading());
    try {
      String result = await authRepository.sendPasswordResetEmail(email);
      emit(Unauthenticated());
      return result;
    } catch (e) {
      return "Error sending password reset email: $e";
    }
  }

  Future<void> deleteAccount() async {
    emit(AuthLoading());
    try {
      await authRepository.deleteAccount();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
      emit(Unauthenticated());
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      final appUser = await authRepository.signInWithGoogle();
      if (appUser == null) {
        emit(Unauthenticated());
        return;
      }
      final isNewUser = authRepository.lastGoogleUserIsNew;
      if (isNewUser) {
        emit(GoogleAuthPendingRegistration(
          googleUser: appUser,
          email: appUser.email,
        ));
      } else {
        // Usuario existente: verificar que existe en la BD
        try {
          final session = await getAuthMeUseCase();
          emit(AuthSuccess(session: session));
        } on DioException catch (e) {
          if (e.response?.statusCode == 401) {
            // Usuario existe en Firebase pero no en la BD
            // Tratar como nuevo usuario para completar registro
            emit(GoogleAuthPendingRegistration(
              googleUser: appUser,
              email: appUser.email,
            ));
            return;
          }
          rethrow;
        }
      }
    } on FirebaseAuthException catch (e) {
      final errorMessage = _getErrorMessage(e.code);
      emit(AuthFailure(error: errorMessage));
      emit(Unauthenticated());
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Usuario existe en Firebase pero no en la BD
        // Tratar como nuevo usuario
        final appUser = await authRepository.getCurrentUser();
        if (appUser != null) {
          emit(GoogleAuthPendingRegistration(
            googleUser: appUser,
            email: appUser.email,
          ));
          return;
        }
        emit(Unauthenticated());
        return;
      }
      emit(AuthFailure(error: e.response?.data?['message']?.toString() ?? e.message ?? 'Error'));
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthFailure(error: 'Ocurrió un error al iniciar sesión con Google. Por favor, intenta de nuevo.'));
      emit(Unauthenticated());
    }
  }

  /// Completa el registro de un usuario autenticado con Google.
  ///
  /// Se llama cuando el usuario se autentica con Google pero es nuevo y necesita
  /// proporcionar nombre y rol antes de acceder a la app.
  ///
  /// [name] - Nombre del usuario
  /// [role] - Rol del usuario: `user` o `sponsor`
  /// [sponsorData] - Datos del sponsor (solo si [role] es `sponsor`)
  ///
  /// Flujo similar a [signUp]: registra en API, crea sponsor si aplica, obtiene sesión.
  ///
  /// Emite:
  /// - [AuthLoading] mientras procesa
  /// - [AuthSuccess] con sesión completa si el registro es exitoso
  /// - [Unauthenticated] si falla
  /// - [AuthFailure] si ocurre un error
  Future<void> completeGoogleRegistration(
    String name,
    String role, {
    CreateSponsorDto? sponsorData,
  }) async {
    emit(AuthLoading());
    try {
      final appUser = await authRepository.completeGoogleRegistration(name, role);
      if (appUser == null) {
        emit(AuthFailure(error: 'Error al completar el registro'));
        emit(Unauthenticated());
        return;
      }
      if (role == 'sponsor' && sponsorData != null) {
        try {
          await createSponsorUseCase(sponsorData);
        } on DioException catch (e) {
          // Si falla al crear sponsor, el usuario ya está en Firebase y API
          // Hacer logout para limpiar estado y permitir reintento
          try {
            await authRepository.signOut();
          } catch (_) {
            // Ignorar errores al hacer logout
          }
          emit(AuthFailure(
            error: e.response?.data?['message']?.toString() ?? 
                'No se pudo crear el perfil de patrocinador. Por favor, intenta nuevamente.',
          ));
          emit(Unauthenticated());
          return;
        }
      }
      final session = await getAuthMeUseCase();
      emit(AuthSuccess(session: session));
    } on DioException catch (e) {
      emit(AuthFailure(error: e.response?.data?['message']?.toString() ?? e.message ?? 'Error'));
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
      emit(Unauthenticated());
    }
  }
}
