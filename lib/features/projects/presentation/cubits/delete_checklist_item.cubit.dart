import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/application/use_cases/delete_checklist_item.use_case.dart';
import 'package:metas_app/features/projects/presentation/cubits/delete_checklist_item.states.dart';

/// Cubit para gestionar el estado de la eliminación de checklist items.
class DeleteChecklistItemCubit extends Cubit<DeleteChecklistItemState> {
  final DeleteChecklistItemUseCase _deleteChecklistItemUseCase;

  DeleteChecklistItemCubit({
    required DeleteChecklistItemUseCase deleteChecklistItemUseCase,
  })  : _deleteChecklistItemUseCase = deleteChecklistItemUseCase,
        super(DeleteChecklistItemInitial());

  Future<void> deleteChecklistItem(String taskId, String id) async {
    emit(DeleteChecklistItemLoading());
    try {
      await _deleteChecklistItemUseCase(taskId, id);
      emit(DeleteChecklistItemSuccess());
    } catch (e) {
      emit(DeleteChecklistItemError(e.toString()));
    }
  }
}
