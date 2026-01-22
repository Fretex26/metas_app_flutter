import 'package:metas_app/features/projects/domain/entities/checklist_item.dart';
import 'package:metas_app/features/projects/domain/repositories/checklist_item.repository.dart';

class GetChecklistItemByIdUseCase {
  final ChecklistItemRepository _repository;

  GetChecklistItemByIdUseCase(this._repository);

  Future<ChecklistItem> call(String taskId, String id) async {
    return await _repository.getChecklistItemById(taskId, id);
  }
}
