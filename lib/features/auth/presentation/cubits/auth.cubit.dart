import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/domain/entities/app_user.dart';
import 'package:metas_app/features/auth/domain/repositories/auth.repository.dart';
import 'package:metas_app/features/auth/presentation/cubits/auth.states.dart';

class AuthCubit extends Cubit<AuthStates> {
  final AuthRepository authRepository;
  AppUser? _currentUser;

  AuthCubit({required this.authRepository}) : super(AuthInitial());

  AppUser? get currentUser => _currentUser;

  void checkAuthStatus() async {
    emit(AuthLoading());
    try {
      _currentUser = await authRepository.getCurrentUser();
      emit(_currentUser != null ? AuthSuccess(user: _currentUser!) : Unauthenticated());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    emit(AuthLoading());
    try {
      _currentUser = await authRepository.signInWithEmailAndPassword(email, password);
      emit(_currentUser != null ? AuthSuccess(user: _currentUser!) : Unauthenticated());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
      emit(Unauthenticated());
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    emit(AuthLoading());
    try {
      _currentUser = await authRepository.signUp(name, email, password);
      final newState = _currentUser != null ? AuthSuccess(user: _currentUser!) : Unauthenticated();
      emit(newState);
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
}
