/// Entidad de dominio que representa un sponsor en el portal de administración.
///
/// Incluye datos del sponsor y del usuario asociado (userId, userName, userEmail).
/// Usada para listar, filtrar y gestionar sponsors (aprobar, rechazar, deshabilitar, habilitar).
class AdminSponsor {
  final String id;
  final String status;
  final String? businessName;
  final String? description;
  final String? contactEmail;
  final String? userId;
  final String? userName;
  final String? userEmail;

  const AdminSponsor({
    required this.id,
    required this.status,
    this.businessName,
    this.description,
    this.contactEmail,
    this.userId,
    this.userName,
    this.userEmail,
  });
}
