import 'package:metas_app/features/projects/domain/entities/checklist_item.dart';
import 'package:metas_app/features/projects/domain/repositories/checklist_item.repository.dart';
import 'package:metas_app/features/projects/infrastructure/dto/update_checklist_item.dto.dart';

class UpdateChecklistItemUseCase {
  final ChecklistItemRepository _repository;

  UpdateChecklistItemUseCase(this._repository);

  Future<ChecklistItem> call(String taskId, String id, UpdateChecklistItemDto dto) async {
    return await _repository.updateChecklistItem(taskId, id, dto);
  }
}
