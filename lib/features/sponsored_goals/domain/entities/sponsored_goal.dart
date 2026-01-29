import 'package:metas_app/features/sponsored_goals/domain/entities/category.dart';
import 'package:metas_app/features/sponsored_goals/domain/entities/verification_method.dart';

/// Entidad que representa un Sponsored Goal (Objetivo Patrocinado) en el dominio.
/// 
/// Un Sponsored Goal es un objetivo creado por un sponsor basado en uno de sus proyectos.
/// Los usuarios normales pueden inscribirse a estos objetivos y trabajar en ellos.
/// 
/// Características principales:
/// - Se basa en un proyecto existente del sponsor
/// - Tiene fechas de inicio y fin
/// - Tiene un método de verificación (siempre "manual" por ahora)
/// - Puede tener categorías asociadas
/// - Tiene un límite máximo de usuarios
/// - Puede tener una recompensa opcional
class SponsoredGoal {
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

  /// Categorías asociadas al objetivo (ManyToMany)
  final List<Category>? categories;

  /// Fecha de inicio del objetivo
  final DateTime startDate;

  /// Fecha de fin del objetivo
  final DateTime endDate;

  /// Método de verificación (siempre "manual" por ahora)
  final VerificationMethod verificationMethod;

  /// ID de la recompensa opcional asociada
  final String? rewardId;

  /// Número máximo de usuarios que pueden inscribirse
  final int maxUsers;

  /// Fecha de creación del objetivo
  final DateTime createdAt;

  /// Constructor de la entidad SponsoredGoal
  SponsoredGoal({
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
}
