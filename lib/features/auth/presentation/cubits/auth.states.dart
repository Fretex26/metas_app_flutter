import 'package:metas_app/features/auth/domain/entities/app_user.dart';
import 'package:metas_app/features/auth/domain/entities/auth_me_session.dart';

/// Estados del cubit de autenticación.
///
/// Gestiona el ciclo de vida de la autenticación: inicial, carga, éxito, error,
/// y casos especiales como registro pendiente de Google.
abstract class AuthStates {}

/// Estado inicial (antes de verificar autenticación).
class AuthInitial extends AuthStates {}

/// Estado de carga (verificando autenticación o procesando login/registro).
class AuthLoading extends AuthStates {}

/// Estado de autenticación exitosa.
///
/// Contiene [session] con datos del usuario y sponsor (si aplica).
/// Usado para redirección post-login según rol y estado del sponsor.
class AuthSuccess extends AuthStates {
  final AuthMeSession session;

  AuthSuccess({required this.session});

  /// Getter de conveniencia para acceder al usuario desde la sesión.
  AuthMeUser get user => session.user;
}

/// Estado de no autenticado (usuario no logueado o sesión expirada).
class Unauthenticated extends AuthStates {}

/// Estado de error en la autenticación.
///
/// Contiene el mensaje de error para mostrar al usuario.
class AuthFailure extends AuthStates {
  final String error;
  AuthFailure({required this.error});
}

/// Estado cuando el usuario se autentica con Google pero necesita completar el registro.
///
/// Se emite cuando el usuario es nuevo y necesita proporcionar nombre y rol
/// antes de poder acceder a la aplicación.
class GoogleAuthPendingRegistration extends AuthStates {
  final AppUser googleUser;
  final String email;

  GoogleAuthPendingRegistration({
    required this.googleUser,
    required this.email,
  });
}
