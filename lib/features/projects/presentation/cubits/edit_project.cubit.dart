import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/application/use_cases/update_project.use_case.dart';
import 'package:metas_app/features/projects/infrastructure/dto/update_project.dto.dart';
import 'package:metas_app/features/projects/presentation/cubits/edit_project.states.dart';

/// Cubit para gestionar el estado de la edición de proyectos.
/// 
/// Maneja la actualización de proyectos y emite estados de carga, éxito y error.
class EditProjectCubit extends Cubit<EditProjectState> {
  /// Caso de uso para actualizar proyectos
  final UpdateProjectUseCase _updateProjectUseCase;

  /// Constructor del cubit
  /// 
  /// [updateProjectUseCase] - Caso de uso para actualizar proyectos
  EditProjectCubit({
    required UpdateProjectUseCase updateProjectUseCase,
  })  : _updateProjectUseCase = updateProjectUseCase,
        super(EditProjectInitial());

  /// Actualiza un proyecto existente.
  /// 
  /// [projectId] - Identificador único del proyecto (UUID)
  /// [dto] - Datos a actualizar (solo los campos que se quieren cambiar)
  /// 
  /// Emite:
  /// - [EditProjectLoading] mientras actualiza
  /// - [EditProjectSuccess] con el proyecto actualizado
  /// - [EditProjectError] si hay un error
  Future<void> updateProject(String projectId, UpdateProjectDto dto) async {
    emit(EditProjectLoading());
    try {
      final updatedProject = await _updateProjectUseCase(projectId, dto);
      emit(EditProjectSuccess(updatedProject));
    } catch (e) {
      emit(EditProjectError(e.toString()));
    }
  }
}
