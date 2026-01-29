import 'package:metas_app/features/sponsored_goals/domain/entities/verification_method.dart';

/// DTO para actualización parcial de un Sponsored Goal (PATCH).
///
/// Todos los campos son opcionales. Solo se envían los que se modifican.
/// projectId y sponsorId no son editables.
class UpdateSponsoredGoalDto {
  final String? name;
  final String? description;
  final List<String>? categoryIds;
  final String? startDate;
  final String? endDate;
  final VerificationMethod? verificationMethod;
  final String? rewardId;
  final int? maxUsers;

  UpdateSponsoredGoalDto({
    this.name,
    this.description,
    this.categoryIds,
    this.startDate,
    this.endDate,
    this.verificationMethod,
    this.rewardId,
    this.maxUsers,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (description != null) map['description'] = description;
    if (categoryIds != null) map['categoryIds'] = categoryIds;
    if (startDate != null) map['startDate'] = startDate;
    if (endDate != null) map['endDate'] = endDate;
    if (verificationMethod != null) {
      map['verificationMethod'] = verificationMethod!.value;
    }
    if (rewardId != null) map['rewardId'] = rewardId;
    if (maxUsers != null) map['maxUsers'] = maxUsers;
    return map;
  }
}
