import 'package:metas_app/features/projects/domain/entities/checklist_item.dart';
import 'package:metas_app/features/projects/domain/repositories/checklist_item.repository.dart';

class GetChecklistItemsUseCase {
  final ChecklistItemRepository _repository;

  GetChecklistItemsUseCase(this._repository);

  Future<List<ChecklistItem>> call(String taskId) async {
    return await _repository.getChecklistItems(taskId);
  }
}
