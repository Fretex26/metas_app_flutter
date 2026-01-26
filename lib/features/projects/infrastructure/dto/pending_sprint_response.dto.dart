import 'package:metas_app/features/projects/domain/entities/pending_sprint.dart';

/// DTO que representa la respuesta del endpoint de sprints pendientes.
/// 
/// Mapea la respuesta JSON del backend a la entidad del dominio.
class PendingSprintResponseDto {
  final String sprintId;
  final String sprintName;
  final String endDate;
  final String projectId;
  final String projectName;
  final String milestoneId;
  final String milestoneName;
  final bool needsReview;
  final bool needsRetrospective;

  PendingSprintResponseDto({
    required this.sprintId,
    required this.sprintName,
    required this.endDate,
    required this.projectId,
    required this.projectName,
    required this.milestoneId,
    required this.milestoneName,
    required this.needsReview,
    required this.needsRetrospective,
  });

  /// Crea un DTO desde un JSON
  factory PendingSprintResponseDto.fromJson(Map<String, dynamic> json) {
    return PendingSprintResponseDto(
      sprintId: json['sprintId'] as String,
      sprintName: json['sprintName'] as String,
      endDate: json['endDate'] as String,
      projectId: json['projectId'] as String,
      projectName: json['projectName'] as String,
      milestoneId: json['milestoneId'] as String,
      milestoneName: json['milestoneName'] as String,
      needsReview: json['needsReview'] as bool,
      needsRetrospective: json['needsRetrospective'] as bool,
    );
  }

  /// Convierte el DTO a la entidad del dominio
  PendingSprint toDomain() {
    return PendingSprint(
      sprintId: sprintId,
      sprintName: sprintName,
      endDate: DateTime.parse(endDate),
      projectId: projectId,
      projectName: projectName,
      milestoneId: milestoneId,
      milestoneName: milestoneName,
      needsReview: needsReview,
      needsRetrospective: needsRetrospective,
    );
  }
}
