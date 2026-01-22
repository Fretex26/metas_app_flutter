import 'package:metas_app/features/projects/domain/entities/milestone.dart';

abstract class EditMilestoneState {}

class EditMilestoneInitial extends EditMilestoneState {}

class EditMilestoneLoading extends EditMilestoneState {}

class EditMilestoneSuccess extends EditMilestoneState {
  final Milestone milestone;
  EditMilestoneSuccess(this.milestone);
}

class EditMilestoneError extends EditMilestoneState {
  final String message;
  EditMilestoneError(this.message);
}
