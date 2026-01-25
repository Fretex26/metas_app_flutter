import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/application/use_cases/get_project_progress.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_user_projects.use_case.dart';
import 'package:metas_app/features/projects/presentation/cubits/projects.states.dart';

/// Cubit para gestionar el estado de la lista de proyectos.
/// 
/// Maneja la carga de proyectos del usuario y sus progresos asociados.
/// Emite estados de carga, éxito y error para que la UI pueda reaccionar.
class ProjectsCubit extends Cubit<ProjectsState> {
  /// Caso de uso para obtener los proyectos del usuario
  final GetUserProjectsUseCase _getUserProjectsUseCase;

  /// Caso de uso para obtener el progreso de cada proyecto
  final GetProjectProgressUseCase _getProjectProgressUseCase;

  /// Constructor del cubit
  /// 
  /// [getUserProjectsUseCase] - Caso de uso para obtener proyectos
  /// [getProjectProgressUseCase] - Caso de uso para obtener progreso
  ProjectsCubit({
    required GetUserProjectsUseCase getUserProjectsUseCase,
    required GetProjectProgressUseCase getProjectProgressUseCase,
  })  : _getUserProjectsUseCase = getUserProjectsUseCase,
        _getProjectProgressUseCase = getProjectProgressUseCase,
        super(ProjectsInitial());

  /// Carga todos los proyectos del usuario y sus progresos.
  /// 
  /// Primero obtiene la lista de proyectos, luego carga el progreso de cada uno
  /// en paralelo para mejorar el rendimiento. Si falla la carga de progreso de
  /// algún proyecto, se omite pero se mantienen los demás.
  /// 
  /// Emite:
  /// - [ProjectsLoading] mientras carga
  /// - [ProjectsLoaded] con los proyectos y progresos
  /// - [ProjectsError] si hay un error
  Future<void> loadProjects() async {
    emit(ProjectsLoading());
    try {
      // Obtener todos los proyectos del usuario
      final projects = await _getUserProjectsUseCase();
      final progressMap = <String, dynamic>{};

      // Cargar progreso para cada proyecto en paralelo para mejor rendimiento
      final progressFutures = projects.map((project) async {
        try {
          final progress = await _getProjectProgressUseCase(project.id);
          return MapEntry(project.id, progress);
        } catch (e) {
          // Si falla la carga de progreso de un proyecto, se omite pero se mantienen los demás
          return null;
        }
      }).toList();

      // Esperar a que todas las peticiones de progreso terminen
      final progressResults = await Future.wait(progressFutures);
      for (var result in progressResults) {
        if (result != null) {
          progressMap[result.key] = result.value;
        }
      }

      emit(ProjectsLoaded(
        projects: projects,
        progressMap: progressMap.map((key, value) => MapEntry(key, value as dynamic)),
      ));
    } catch (e) {
      emit(ProjectsError(e.toString()));
    }
  }
}
