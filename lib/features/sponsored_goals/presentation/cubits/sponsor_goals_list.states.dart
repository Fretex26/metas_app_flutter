import 'package:metas_app/features/sponsored_goals/domain/entities/sponsored_goal.dart';

/// Estados del cubit de lista de objetivos del sponsor.
abstract class SponsorGoalsListState {}

class SponsorGoalsListInitial extends SponsorGoalsListState {}

class SponsorGoalsListLoading extends SponsorGoalsListState {}

class SponsorGoalsListLoaded extends SponsorGoalsListState {
  final List<SponsoredGoal> goals;

  SponsorGoalsListLoaded({required this.goals});
}

class SponsorGoalsListError extends SponsorGoalsListState {
  final String message;

  SponsorGoalsListError(this.message);
}
