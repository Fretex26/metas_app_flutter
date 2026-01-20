import 'package:metas_app/features/auth/domain/entities/app_user.dart';

abstract class AuthStates {}

class AuthInitial extends AuthStates {}

class AuthLoading extends AuthStates {}

class AuthSuccess extends AuthStates {
  final AppUser user;
  AuthSuccess({required this.user});
}

class Unauthenticated extends AuthStates {}

class AuthFailure extends AuthStates {
  final String error;
  AuthFailure({required this.error});
}

class GoogleAuthPendingRegistration extends AuthStates {
  final AppUser googleUser; // Usuario autenticado con Google pero sin completar registro
  final String email;
  GoogleAuthPendingRegistration({required this.googleUser, required this.email});
}