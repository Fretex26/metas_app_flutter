import 'package:metas_app/features/admin/domain/entities/admin_sponsor.dart';
import 'package:metas_app/features/admin/infrastructure/dto/admin_sponsor_response.dto.dart';

/// Mapper para convertir [AdminSponsorResponseDto] (capa de infraestructura) a [AdminSponsor] (dominio).
///
/// Mapea los datos del sponsor y del usuario asociado desde el DTO de respuesta
/// de los endpoints de administración a la entidad de dominio.
extension AdminSponsorResponseDtoMapper on AdminSponsorResponseDto {
  /// Convierte el DTO a entidad de dominio.
  ///
  /// Extrae los datos del usuario desde el campo `user` (Map) y los mapea
  /// a campos individuales (userId, userName, userEmail) en [AdminSponsor].
  AdminSponsor toDomain() {
    final u = user;
    return AdminSponsor(
      id: id,
      status: status,
      businessName: businessName,
      description: description,
      contactEmail: contactEmail,
      userId: u != null ? u['id'] as String? : null,
      userName: u != null ? u['name'] as String? : null,
      userEmail: u != null ? u['email'] as String? : null,
    );
  }
}
