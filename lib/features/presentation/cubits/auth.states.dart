import 'package:metas_app/features/domain/entities/app_user.dart';

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