import 'package:metas_app/features/auth/domain/entities/auth_me_session.dart';
import 'package:metas_app/features/auth/infrastructure/dto/auth_me_response.dto.dart';

/// Mapper para convertir [AuthMeResponseDto] (capa de infraestructura) a [AuthMeSession] (dominio).
///
/// Mapea los datos del usuario y sponsor (si existe) desde el DTO de respuesta
/// del endpoint [GET /api/auth/me] a la entidad de dominio.
extension AuthMeResponseDtoMapper on AuthMeResponseDto {
  /// Convierte el DTO a entidad de dominio.
  ///
  /// Retorna [AuthMeSession] con [AuthMeUser] y [AuthMeSponsor] (si aplica).
  AuthMeSession toDomain() {
    return AuthMeSession(
      user: AuthMeUser(
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
      ),
      sponsor: sponsor != null
          ? AuthMeSponsor(
              id: sponsor!.id,
              status: sponsor!.status,
              businessName: sponsor!.businessName,
            )
          : null,
    );
  }
}
