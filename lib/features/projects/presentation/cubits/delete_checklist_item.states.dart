abstract class DeleteChecklistItemState {}

class DeleteChecklistItemInitial extends DeleteChecklistItemState {}

class DeleteChecklistItemLoading extends DeleteChecklistItemState {}

class DeleteChecklistItemSuccess extends DeleteChecklistItemState {}

class DeleteChecklistItemError extends DeleteChecklistItemState {
  final String message;
  DeleteChecklistItemError(this.message);
}
