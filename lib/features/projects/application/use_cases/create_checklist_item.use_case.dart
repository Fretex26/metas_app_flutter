import 'package:metas_app/features/projects/domain/entities/checklist_item.dart';
import 'package:metas_app/features/projects/domain/repositories/checklist_item.repository.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_checklist_item.dto.dart';

class CreateChecklistItemUseCase {
  final ChecklistItemRepository _repository;

  CreateChecklistItemUseCase(this._repository);

  Future<ChecklistItem> call(String taskId, CreateChecklistItemDto dto) async {
    return await _repository.createChecklistItem(taskId, dto);
  }
}
