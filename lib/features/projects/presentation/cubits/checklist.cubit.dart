import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/application/use_cases/create_checklist_item.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_checklist_items.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/update_checklist_item.use_case.dart';
import 'package:metas_app/features/projects/domain/entities/checklist_item.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_checklist_item.dto.dart';
import 'package:metas_app/features/projects/infrastructure/dto/update_checklist_item.dto.dart';
import 'package:metas_app/features/projects/presentation/cubits/checklist.states.dart';

/// Cubit para gestionar el estado de los checklist items de una task.
/// 
/// Maneja la carga, creación y actualización de checklist items.
/// Al marcar/desmarcar items, el estado de la task se actualiza automáticamente
/// en el backend según las reglas de dependencias.
class ChecklistCubit extends Cubit<ChecklistState> {
  /// Caso de uso para obtener checklist items
  final GetChecklistItemsUseCase _getChecklistItemsUseCase;

  /// Caso de uso para crear checklist items
  final CreateChecklistItemUseCase _createChecklistItemUseCase;

  /// Caso de uso para actualizar checklist items
  final UpdateChecklistItemUseCase _updateChecklistItemUseCase;

  /// Constructor del cubit
  /// 
  /// [getChecklistItemsUseCase] - Caso de uso para obtener items
  /// [createChecklistItemUseCase] - Caso de uso para crear items
  /// [updateChecklistItemUseCase] - Caso de uso para actualizar items
  ChecklistCubit({
    required GetChecklistItemsUseCase getChecklistItemsUseCase,
    required CreateChecklistItemUseCase createChecklistItemUseCase,
    required UpdateChecklistItemUseCase updateChecklistItemUseCase,
  })  : _getChecklistItemsUseCase = getChecklistItemsUseCase,
        _createChecklistItemUseCase = createChecklistItemUseCase,
        _updateChecklistItemUseCase = updateChecklistItemUseCase,
        super(ChecklistInitial());

  Future<void> loadChecklistItems(String taskId) async {
    emit(ChecklistLoading());
    try {
      final items = await _getChecklistItemsUseCase(taskId);
      emit(ChecklistLoaded(items));
    } catch (e) {
      emit(ChecklistError(e.toString()));
    }
  }

  Future<void> createChecklistItem(String taskId, CreateChecklistItemDto dto) async {
    try {
      await _createChecklistItemUseCase(taskId, dto);
      await loadChecklistItems(taskId);
    } catch (e) {
      emit(ChecklistError(e.toString()));
    }
  }

  Future<void> toggleChecklistItem(String taskId, ChecklistItem item) async {
    if (state is ChecklistLoaded) {
      final currentItems = (state as ChecklistLoaded).items;
      emit(ChecklistItemUpdating(currentItems, item.id));
    }

    try {
      await _updateChecklistItemUseCase(
        taskId,
        item.id,
        UpdateChecklistItemDto(isChecked: !item.isChecked),
      );
      await loadChecklistItems(taskId);
    } catch (e) {
      emit(ChecklistError(e.toString()));
    }
  }

  /// Actualiza un checklist item existente.
  /// 
  /// [taskId] - Identificador único de la task
  /// [itemId] - Identificador único del checklist item
  /// [dto] - Datos a actualizar
  /// 
  /// Emite:
  /// - [ChecklistItemUpdating] mientras actualiza
  /// - [ChecklistItemUpdated] con el item actualizado
  /// - [ChecklistError] si hay un error
  Future<void> updateChecklistItem(String taskId, String itemId, UpdateChecklistItemDto dto) async {
    if (state is ChecklistLoaded) {
      final currentItems = (state as ChecklistLoaded).items;
      emit(ChecklistItemUpdating(currentItems, itemId));
    }

    try {
      final updatedItem = await _updateChecklistItemUseCase(taskId, itemId, dto);
      emit(ChecklistItemUpdated(updatedItem));
      await loadChecklistItems(taskId);
    } catch (e) {
      emit(ChecklistError(e.toString()));
    }
  }
}
