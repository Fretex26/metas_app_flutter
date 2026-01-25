import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/application/use_cases/delete_project.use_case.dart';
import 'package:metas_app/features/projects/presentation/cubits/delete_project.states.dart';

/// Cubit para gestionar el estado de la eliminación de proyectos.
class DeleteProjectCubit extends Cubit<DeleteProjectState> {
  final DeleteProjectUseCase _deleteProjectUseCase;

  DeleteProjectCubit({
    required DeleteProjectUseCase deleteProjectUseCase,
  })  : _deleteProjectUseCase = deleteProjectUseCase,
        super(DeleteProjectInitial());

  Future<void> deleteProject(String projectId) async {
    emit(DeleteProjectLoading());
    try {
      await _deleteProjectUseCase(projectId);
      emit(DeleteProjectSuccess());
    } catch (e) {
      emit(DeleteProjectError(e.toString()));
    }
  }
}
