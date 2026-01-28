import 'package:metas_app/features/auth/domain/entities/auth_me_session.dart';
import 'package:metas_app/features/auth/infrastructure/datasources/auth_me_datasource.dart';
import 'package:metas_app/features/auth/infrastructure/mappers/auth_me.mapper.dart';

/// Use case para obtener la sesión actual del usuario autenticado.
///
/// Llama a [GET /api/auth/me] y retorna [AuthMeSession] con datos del usuario
/// y del sponsor (si aplica). Usado para redirección post-login y control de acceso.
///
/// Requiere que el usuario esté autenticado en Firebase (token válido).
class GetAuthMeUseCase {
  final AuthMeDatasource _datasource;

  /// Constructor del use case.
  ///
  /// [datasource] - Datasource opcional para inyección de dependencias (testing).
  GetAuthMeUseCase([AuthMeDatasource? datasource])
      : _datasource = datasource ?? AuthMeDatasource();

  /// Ejecuta el use case.
  ///
  /// Retorna [AuthMeSession] con:
  /// - [AuthMeUser]: id, name, email, role (user | sponsor | admin)
  /// - [AuthMeSponsor]?: id, status (pending | approved | rejected | disabled), businessName
  ///
  /// Lanza excepción si:
  /// - El usuario no está autenticado
  /// - Error de red o del servidor
  Future<AuthMeSession> call() async {
    final dto = await _datasource.getAuthMe();
    return dto.toDomain();
  }
}
