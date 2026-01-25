abstract class CreateMilestoneState {}

class CreateMilestoneInitial extends CreateMilestoneState {}

class CreateMilestoneLoading extends CreateMilestoneState {}

class CreateMilestoneSuccess extends CreateMilestoneState {
  final String milestoneId;

  CreateMilestoneSuccess(this.milestoneId);
}

class CreateMilestoneError extends CreateMilestoneState {
  final String message;

  CreateMilestoneError(this.message);
}
