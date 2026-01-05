import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/domain/entities/app_user.dart';
import 'package:metas_app/features/domain/repositories/auth.repository.dart';
import 'package:metas_app/features/presentation/cubits/auth.states.dart';

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
}
