/// DTO para crear una solicitud de patrocinador.
///
/// Usado en [POST /api/sponsors] durante el registro cuando el usuario elige ser sponsor.
/// El sponsor queda con estado **PENDING** hasta aprobación del administrador.
///
/// Campos requeridos:
/// - [businessName]: Nombre del negocio
/// - [description]: Descripción del negocio
/// - [category]: Categoría del negocio
/// - [contactEmail]: Email de contacto
///
/// Campos opcionales:
/// - [logoUrl]: URL del logo del negocio (opcional)
class CreateSponsorDto {
  final String businessName;
  final String description;
  final String category;
  final String contactEmail;
  final String? logoUrl;

  const CreateSponsorDto({
    required this.businessName,
    required this.description,
    required this.category,
    required this.contactEmail,
    this.logoUrl,
  });

  Map<String, dynamic> toJson() => {
        'businessName': businessName,
        'description': description,
        'category': category,
        'contactEmail': contactEmail,
        if (logoUrl != null && logoUrl!.isNotEmpty) 'logoUrl': logoUrl,
      };
}
