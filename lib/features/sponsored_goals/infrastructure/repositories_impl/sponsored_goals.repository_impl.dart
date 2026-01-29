import 'package:metas_app/features/projects/domain/entities/milestone.dart';
import 'package:metas_app/features/projects/domain/entities/project.dart';
import 'package:metas_app/features/projects/infrastructure/mappers/milestone.mapper.dart';
import 'package:metas_app/features/projects/infrastructure/mappers/project.mapper.dart';
import 'package:metas_app/features/sponsored_goals/domain/entities/category.dart';
import 'package:metas_app/features/sponsored_goals/domain/entities/sponsor_enrollment.dart';
import 'package:metas_app/features/sponsored_goals/domain/entities/sponsored_goal.dart';
import 'package:metas_app/features/sponsored_goals/domain/repositories/sponsored_goals.repository.dart';
import 'package:metas_app/features/sponsored_goals/infrastructure/datasources/sponsored_goals_datasource.dart';
import 'package:metas_app/features/sponsored_goals/infrastructure/dto/create_sponsored_goal.dto.dart';
import 'package:metas_app/features/sponsored_goals/infrastructure/dto/update_enrollment_status.dto.dart';
import 'package:metas_app/features/sponsored_goals/infrastructure/dto/update_sponsored_goal.dto.dart';
import 'package:metas_app/features/sponsored_goals/infrastructure/mappers/category.mapper.dart';
import 'package:metas_app/features/sponsored_goals/infrastructure/mappers/sponsor_enrollment.mapper.dart';
import 'package:metas_app/features/sponsored_goals/infrastructure/mappers/sponsored_goal.mapper.dart';

/// Implementación concreta del repositorio de Sponsored Goals.
/// 
/// Conecta la capa de dominio con la capa de infraestructura, utilizando
/// el datasource para obtener datos y los mappers para convertir DTOs a entidades.
/// 
/// Esta implementación sigue el patrón Repository de Clean Architecture.
class SponsoredGoalsRepositoryImpl implements SponsoredGoalsRepository {
  /// Datasource para realizar las llamadas HTTP al backend
  final SponsoredGoalsDatasource _datasource;

  /// Constructor del repositorio implementado
  /// 
  /// [datasource] - Datasource opcional para inyección de dependencias (útil para testing)
  SponsoredGoalsRepositoryImpl({SponsoredGoalsDatasource? datasource})
      : _datasource = datasource ?? SponsoredGoalsDatasource();

  @override
  Future<SponsoredGoal> createSponsoredGoal(
    CreateSponsoredGoalDto dto,
  ) async {
    try {
      final responseDto = await _datasource.createSponsoredGoal(dto);
      return responseDto.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<SponsoredGoal>> listSponsorSponsoredGoals() async {
    try {
      final dtos = await _datasource.listSponsorSponsoredGoals();
      return dtos.map((dto) => dto.toDomain()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SponsoredGoal> getSponsoredGoalById(String id) async {
    try {
      final dto = await _datasource.getSponsoredGoalById(id);
      return dto.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SponsoredGoal> updateSponsoredGoal(
    String id,
    UpdateSponsoredGoalDto dto,
  ) async {
    try {
      final dtoOut = await _datasource.updateSponsoredGoal(id, dto);
      return dtoOut.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteSponsoredGoal(String id) async {
    try {
      await _datasource.deleteSponsoredGoal(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<SponsoredGoal>> getAvailableSponsoredGoals({
    List<String>? categoryIds,
  }) async {
    try {
      final dtos = await _datasource.getAvailableSponsoredGoals(
        categoryIds: categoryIds,
      );
      return dtos.map((dto) => dto.toDomain()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SponsorEnrollment> enrollInSponsoredGoal(
    String sponsoredGoalId,
  ) async {
    try {
      final responseDto = await _datasource.enrollInSponsoredGoal(sponsoredGoalId);
      return responseDto.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SponsorEnrollment> updateEnrollmentStatus(
    String enrollmentId,
    UpdateEnrollmentStatusDto dto,
  ) async {
    try {
      final responseDto = await _datasource.updateEnrollmentStatus(
        enrollmentId,
        dto,
      );
      return responseDto.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Milestone> verifyMilestone(String milestoneId) async {
    try {
      final responseDto = await _datasource.verifyMilestone(milestoneId);
      return responseDto.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Project>> getUserSponsoredProjects(String userEmail) async {
    try {
      final dtos = await _datasource.getUserSponsoredProjects(userEmail);
      return dtos.map((dto) => dto.toDomain()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Milestone>> getSponsoredProjectMilestones(String projectId) async {
    try {
      final dtos = await _datasource.getProjectMilestones(projectId);
      return dtos.map((dto) => dto.toDomain()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    try {
      final dtos = await _datasource.getCategories();
      return dtos.map((dto) => dto.toDomain()).toList();
    } catch (e) {
      rethrow;
    }
  }
}
