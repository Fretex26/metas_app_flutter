import 'package:metas_app/features/projects/domain/entities/retrospective.dart';

abstract class GetSprintRetrospectiveState {}

class GetSprintRetrospectiveInitial extends GetSprintRetrospectiveState {}

class GetSprintRetrospectiveLoading extends GetSprintRetrospectiveState {}

class GetSprintRetrospectiveLoaded extends GetSprintRetrospectiveState {
  final Retrospective? retrospective;

  GetSprintRetrospectiveLoaded(this.retrospective);
}

class GetSprintRetrospectiveError extends GetSprintRetrospectiveState {
  final String message;

  GetSprintRetrospectiveError(this.message);
}
