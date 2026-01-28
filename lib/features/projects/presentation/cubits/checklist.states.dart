import 'package:metas_app/features/projects/domain/entities/checklist_item.dart';

abstract class ChecklistState {}

class ChecklistInitial extends ChecklistState {}

class ChecklistLoading extends ChecklistState {}

class ChecklistLoaded extends ChecklistState {
  final List<ChecklistItem> items;

  ChecklistLoaded(this.items);
}

class ChecklistError extends ChecklistState {
  final String message;

  ChecklistError(this.message);
}

class ChecklistItemUpdating extends ChecklistState {
  final List<ChecklistItem> items;
  final String updatingItemId;

  ChecklistItemUpdating(this.items, this.updatingItemId);
}

class ChecklistItemUpdated extends ChecklistState {
  final ChecklistItem item;

  ChecklistItemUpdated(this.item);
}

class ChecklistItemCreated extends ChecklistState {
  final List<ChecklistItem> items;

  ChecklistItemCreated(this.items);
}