import 'package:firebase_auth/firebase_auth.dart';
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
    } on FirebaseAuthException catch (e) {
      final errorMessage = _getErrorMessage(e.code);
      emit(AuthFailure(error: errorMessage));
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

  Future<void> signUp(String name, String email, String password) async {
    emit(AuthLoading());
    try {
      _currentUser = await authRepository.signUp(name, email, password);
      final newState = _currentUser != null ? AuthSuccess(user: _currentUser!) : Unauthenticated();
      emit(newState);
    } on FirebaseAuthException catch (e) {
      final errorMessage = _getErrorMessage(e.code);
      emit(AuthFailure(error: errorMessage));
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthFailure(error: 'Ocurrió un error inesperado. Por favor, intenta de nuevo.'));
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
      _currentUser = await authRepository.signInWithGoogle();
      if (_currentUser == null) {
        // Usuario canceló el proceso de inicio de sesión
        emit(Unauthenticated());
        return;
      }
      emit(AuthSuccess(user: _currentUser!));
    } on FirebaseAuthException catch (e) {
      final errorMessage = _getErrorMessage(e.code);
      emit(AuthFailure(error: errorMessage));
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthFailure(error: 'Ocurrió un error al iniciar sesión con Google. Por favor, intenta de nuevo.'));
      emit(Unauthenticated());
    }
  }
}
