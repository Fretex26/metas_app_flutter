/// DTO de respuesta para sponsors en el portal de administración.
///
/// Usado en:
/// - GET /api/admin/sponsors/pending
/// - GET /api/admin/sponsors
/// - GET /api/admin/sponsors/:id
///
/// Incluye datos del sponsor y del usuario asociado (en el campo `user`).
class AdminSponsorResponseDto {
  final String id;
  final String status;
  final String? businessName;
  final String? description;
  final String? contactEmail;
  final Map<String, dynamic>? user;

  const AdminSponsorResponseDto({
    required this.id,
    required this.status,
    this.businessName,
    this.description,
    this.contactEmail,
    this.user,
  });

  /// Crea el DTO desde JSON.
  ///
  /// [json] debe contener:
  /// - id: String (UUID del sponsor)
  /// - status: String (pending | approved | rejected | disabled)
  /// - businessName, description, contactEmail: String? (opcionales)
  /// - user: Map<String, dynamic>? con id, name, email (opcional)
  factory AdminSponsorResponseDto.fromJson(Map<String, dynamic> json) {
    return AdminSponsorResponseDto(
      id: json['id'] as String,
      status: (json['status'] as String?) ?? 'pending',
      businessName: json['businessName'] as String?,
      description: json['description'] as String?,
      contactEmail: json['contactEmail'] as String?,
      user: json['user'] != null
          ? json['user'] as Map<String, dynamic>
          : null,
    );
  }
}
