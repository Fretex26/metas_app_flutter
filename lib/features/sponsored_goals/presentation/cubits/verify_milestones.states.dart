import 'package:metas_app/features/projects/domain/entities/milestone.dart';
import 'package:metas_app/features/projects/domain/entities/project.dart';

/// Estados posibles del cubit para verificar milestones de proyectos patrocinados.
/// 
/// Define todos los estados que puede tener la verificación de milestones:
/// - Estado inicial
/// - Cargando proyectos/milestones
/// - Cargado con éxito
/// - Verificando milestone
/// - Milestone verificada
/// - Error
abstract class VerifyMilestonesState {}

/// Estado inicial antes de cargar datos
class VerifyMilestonesInitial extends VerifyMilestonesState {}

/// Estado mientras se están cargando los proyectos del usuario
class VerifyMilestonesLoadingProjects extends VerifyMilestonesState {}

/// Estado mientras se están cargando las milestones del proyecto
class VerifyMilestonesLoadingMilestones extends VerifyMilestonesState {}

/// Estado cuando los datos se han cargado exitosamente.
/// 
/// Contiene la lista de proyectos y las milestones del proyecto seleccionado.
class VerifyMilestonesLoaded extends VerifyMilestonesState {
  /// Lista de proyectos patrocinados del usuario
  final List<Project> projects;

  /// Proyecto actualmente seleccionado
  final Project? selectedProject;

  /// Milestones del proyecto seleccionado
  final List<Milestone> milestones;

  /// Constructor del estado de datos cargados
  VerifyMilestonesLoaded({
    required this.projects,
    this.selectedProject,
    required this.milestones,
  });

  /// Crea una copia del estado con nuevos valores
  VerifyMilestonesLoaded copyWith({
    List<Project>? projects,
    Project? selectedProject,
    List<Milestone>? milestones,
  }) {
    return VerifyMilestonesLoaded(
      projects: projects ?? this.projects,
      selectedProject: selectedProject ?? this.selectedProject,
      milestones: milestones ?? this.milestones,
    );
  }
}

/// Estado mientras se está verificando una milestone
class VerifyMilestonesVerifying extends VerifyMilestonesState {
  /// ID de la milestone que se está verificando
  final String milestoneId;

  /// Constructor del estado de verificación en progreso
  VerifyMilestonesVerifying({required this.milestoneId});
}

/// Estado cuando una milestone se ha verificado exitosamente.
/// 
/// Contiene la milestone verificada.
class VerifyMilestonesVerified extends VerifyMilestonesState {
  /// Milestone verificada
  final Milestone milestone;

  /// Constructor del estado de verificación exitosa
  VerifyMilestonesVerified({required this.milestone});
}

/// Estado cuando ocurre un error.
/// 
/// Contiene el mensaje de error para mostrarlo al usuario.
class VerifyMilestonesError extends VerifyMilestonesState {
  /// Mensaje descriptivo del error ocurrido
  final String message;

  /// Constructor del estado de error
  VerifyMilestonesError(this.message);
}
