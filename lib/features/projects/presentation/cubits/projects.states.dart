import 'package:metas_app/features/projects/domain/entities/project.dart';
import 'package:metas_app/features/projects/domain/entities/project_progress.dart';

/// Estados posibles del cubit de lista de proyectos.
/// 
/// Define todos los estados que puede tener la lista de proyectos:
/// - Estado inicial
/// - Cargando
/// - Cargado con éxito
/// - Error
abstract class ProjectsState {}

/// Estado inicial antes de cargar los proyectos
class ProjectsInitial extends ProjectsState {}

/// Estado mientras se están cargando los proyectos del servidor
class ProjectsLoading extends ProjectsState {}

/// Estado cuando los proyectos se han cargado exitosamente.
/// 
/// Contiene la lista de proyectos y un mapa con el progreso de cada uno,
/// donde la clave es el ID del proyecto y el valor es su progreso.
class ProjectsLoaded extends ProjectsState {
  /// Lista de proyectos del usuario
  final List<Project> projects;

  /// Mapa que asocia cada proyecto (por ID) con su progreso
  final Map<String, ProjectProgress> progressMap;

  /// Constructor del estado de proyectos cargados
  ProjectsLoaded({
    required this.projects,
    required this.progressMap,
  });
}

/// Estado cuando ocurre un error al cargar los proyectos.
/// 
/// Contiene el mensaje de error para mostrarlo al usuario.
class ProjectsError extends ProjectsState {
  /// Mensaje descriptivo del error ocurrido
  final String message;

  /// Constructor del estado de error
  ProjectsError(this.message);
}
