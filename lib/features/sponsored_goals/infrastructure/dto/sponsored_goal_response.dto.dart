import 'package:metas_app/features/sponsored_goals/infrastructure/dto/category_response.dto.dart';

/// DTO que representa la respuesta del backend para un Sponsored Goal.
/// 
/// Contiene todos los campos que el backend retorna al obtener o crear un sponsored goal.
/// Las fechas vienen como strings en formato ISO y se convierten a DateTime
/// en el mapper correspondiente.
class SponsoredGoalResponseDto {
  /// Identificador único del sponsored goal (UUID)
  final String id;

  /// Identificador del sponsor que creó el objetivo
  final String sponsorId;

  /// Identificador del proyecto original del sponsor
  final String projectId;

  /// Nombre del objetivo patrocinado
  final String name;

  /// Descripción opcional del objetivo
  final String? description;

  /// Categorías asociadas al objetivo
  final List<CategoryResponseDto>? categories;

  /// Fecha de inicio en formato ISO string
  final String startDate;

  /// Fecha de fin en formato ISO string
  final String endDate;

  /// Método de verificación (string del backend)
  final String verificationMethod;

  /// ID de la recompensa opcional asociada
  final String? rewardId;

  /// Número máximo de usuarios que pueden inscribirse
  final int maxUsers;

  /// Fecha de creación en formato ISO string
  final String createdAt;

  /// Constructor del DTO de respuesta de sponsored goal
  SponsoredGoalResponseDto({
    required this.id,
    required this.sponsorId,
    required this.projectId,
    required this.name,
    this.description,
    this.categories,
    required this.startDate,
    required this.endDate,
    required this.verificationMethod,
    this.rewardId,
    required this.maxUsers,
    required this.createdAt,
  });

  factory SponsoredGoalResponseDto.fromJson(Map<String, dynamic> json) {
    return SponsoredGoalResponseDto(
      id: json['id'] as String,
      sponsorId: json['sponsorId'] as String,
      projectId: json['projectId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      categories: json['categories'] != null
          ? (json['categories'] as List<dynamic>)
              .map((e) => CategoryResponseDto.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      verificationMethod: json['verificationMethod'] as String,
      rewardId: json['rewardId'] as String?,
      maxUsers: json['maxUsers'] as int,
      createdAt: json['createdAt'] as String,
    );
  }

  /// Convierte el DTO a formato JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sponsorId': sponsorId,
      'projectId': projectId,
      'name': name,
      if (description != null) 'description': description,
      if (categories != null)
        'categories': categories!.map((e) => e.toJson()).toList(),
      'startDate': startDate,
      'endDate': endDate,
      'verificationMethod': verificationMethod,
      if (rewardId != null) 'rewardId': rewardId,
      'maxUsers': maxUsers,
      'createdAt': createdAt,
    };
  }
}
