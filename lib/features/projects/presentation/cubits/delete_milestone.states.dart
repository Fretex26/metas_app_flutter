abstract class DeleteMilestoneState {}

class DeleteMilestoneInitial extends DeleteMilestoneState {}

class DeleteMilestoneLoading extends DeleteMilestoneState {}

class DeleteMilestoneSuccess extends DeleteMilestoneState {}

class DeleteMilestoneError extends DeleteMilestoneState {
  final String message;
  DeleteMilestoneError(this.message);
}
