import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/domain/entities/milestone.dart';
import 'package:metas_app/features/sponsored_goals/application/use_cases/get_project_milestones.use_case.dart';
import 'package:metas_app/features/sponsored_goals/application/use_cases/get_user_sponsored_projects.use_case.dart';
import 'package:metas_app/features/sponsored_goals/application/use_cases/update_sponsored_milestone_status.use_case.dart';
import 'package:metas_app/features/sponsored_goals/application/use_cases/verify_milestone.use_case.dart';
import 'package:metas_app/features/sponsored_goals/presentation/cubits/verify_milestones.states.dart';

/// Cubit para gestionar el estado de la verificación de milestones.
///
/// Maneja la búsqueda de usuarios, carga de proyectos patrocinados y milestones,
/// y la verificación de milestones por parte de sponsors.
/// Emite estados de carga, éxito y error para que la UI pueda reaccionar.
class VerifyMilestonesCubit extends Cubit<VerifyMilestonesState> {
  /// Caso de uso para obtener proyectos patrocinados de un usuario
  final GetUserSponsoredProjectsUseCase _getUserSponsoredProjectsUseCase;

  /// Caso de uso para obtener milestones de un proyecto
  final GetSponsoredProjectMilestonesUseCase _getProjectMilestonesUseCase;

  /// Caso de uso para verificar una milestone
  final VerifyMilestoneUseCase _verifyMilestoneUseCase;
  final UpdateSponsoredMilestoneStatusUseCase
  _updateSponsoredMilestoneStatusUseCase;

  /// Constructor del cubit
  ///
  /// [getUserSponsoredProjectsUseCase] - Caso de uso para obtener proyectos
  /// [getProjectMilestonesUseCase] - Caso de uso para obtener milestones
  /// [verifyMilestoneUseCase] - Caso de uso para verificar milestone
  VerifyMilestonesCubit({
    required GetUserSponsoredProjectsUseCase getUserSponsoredProjectsUseCase,
    required GetSponsoredProjectMilestonesUseCase getProjectMilestonesUseCase,
    required VerifyMilestoneUseCase verifyMilestoneUseCase,
    required UpdateSponsoredMilestoneStatusUseCase
    updateSponsoredMilestoneStatusUseCase,
  }) : _getUserSponsoredProjectsUseCase = getUserSponsoredProjectsUseCase,
       _getProjectMilestonesUseCase = getProjectMilestonesUseCase,
       _verifyMilestoneUseCase = verifyMilestoneUseCase,
       _updateSponsoredMilestoneStatusUseCase =
           updateSponsoredMilestoneStatusUseCase,
       super(VerifyMilestonesInitial());

  /// Carga los proyectos patrocinados de un usuario.
  ///
  /// [userEmail] - Email del usuario del cual obtener los proyectos
  ///
  /// Emite:
  /// - [VerifyMilestonesLoadingProjects] mientras carga
  /// - [VerifyMilestonesLoaded] con los proyectos (sin milestones aún)
  /// - [VerifyMilestonesError] si hay un error
  Future<void> loadUserProjects(String userEmail) async {
    emit(VerifyMilestonesLoadingProjects());
    try {
      final projects = await _getUserSponsoredProjectsUseCase(userEmail);
      emit(
        VerifyMilestonesLoaded(
          projects: projects,
          selectedProject: null,
          milestones: [],
        ),
      );
    } catch (e) {
      emit(VerifyMilestonesError(e.toString()));
    }
  }

  /// Carga las milestones de un proyecto patrocinado.
  ///
  /// [projectId] - Identificador único del proyecto
  ///
  /// Emite:
  /// - [VerifyMilestonesLoadingMilestones] mientras carga
  /// - [VerifyMilestonesLoaded] con los proyectos y milestones actualizados
  /// - [VerifyMilestonesError] si hay un error
  Future<void> loadProjectMilestones(String projectId) async {
    final currentState = state;
    if (currentState is! VerifyMilestonesLoaded) {
      return;
    }

    emit(VerifyMilestonesLoadingMilestones());
    try {
      final milestones = await _getProjectMilestonesUseCase(projectId);
      final selectedProject = currentState.projects.firstWhere(
        (p) => p.id == projectId,
      );

      emit(
        VerifyMilestonesLoaded(
          projects: currentState.projects,
          selectedProject: selectedProject,
          milestones: milestones,
        ),
      );
    } catch (e) {
      emit(VerifyMilestonesError(e.toString()));
    }
  }

  /// Verifica una milestone de un proyecto patrocinado.
  ///
  /// [milestoneId] - Identificador único de la milestone
  ///
  /// Emite:
  /// - [VerifyMilestonesVerifying] mientras se verifica
  /// - [VerifyMilestonesVerified] con la milestone verificada
  /// - [VerifyMilestonesError] si hay un error
  ///
  /// Nota: Solo funciona para proyectos con verificationMethod: MANUAL.
  Future<void> verifyMilestone(String milestoneId) async {
    final loadedState = _resolveLoadedState();
    if (loadedState != null) {
      emit(
        VerifyMilestonesUpdatingStatus(
          milestoneId: milestoneId,
          previousState: loadedState,
        ),
      );
    } else {
      emit(VerifyMilestonesVerifying(milestoneId: milestoneId));
    }

    try {
      final verifiedMilestone = await _verifyMilestoneUseCase(milestoneId);
      _emitUpdatedMilestone(verifiedMilestone);
    } catch (e) {
      emit(VerifyMilestonesError(e.toString()));
    }
  }

  Future<void> updateMilestoneStatus(String milestoneId, String status) async {
    final loadedState = _resolveLoadedState();
    if (loadedState == null) return;

    emit(
      VerifyMilestonesUpdatingStatus(
        milestoneId: milestoneId,
        previousState: loadedState,
      ),
    );

    try {
      final updatedMilestone = await _updateSponsoredMilestoneStatusUseCase(
        milestoneId,
        status,
      );
      _emitUpdatedMilestone(updatedMilestone);
    } catch (e) {
      emit(VerifyMilestonesError(e.toString()));
      emit(loadedState);
    }
  }

  VerifyMilestonesLoaded? _resolveLoadedState() {
    final currentState = state;
    if (currentState is VerifyMilestonesLoaded) return currentState;
    if (currentState is VerifyMilestonesUpdatingStatus) {
      return currentState.previousState;
    }
    return null;
  }

  void _emitUpdatedMilestone(Milestone milestone) {
    final loadedState = _resolveLoadedState();
    if (loadedState == null) {
      emit(VerifyMilestonesVerified(milestone: milestone));
      return;
    }

    final updatedMilestones = loadedState.milestones.map((m) {
      if (m.id == milestone.id) {
        return milestone;
      }
      return m;
    }).toList();

    emit(loadedState.copyWith(milestones: updatedMilestones));
  }
}
