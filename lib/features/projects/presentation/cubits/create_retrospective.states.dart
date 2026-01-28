abstract class CreateRetrospectiveState {}

class CreateRetrospectiveInitial extends CreateRetrospectiveState {}

class CreateRetrospectiveLoading extends CreateRetrospectiveState {}

class CreateRetrospectiveSuccess extends CreateRetrospectiveState {
  final String retrospectiveId;

  CreateRetrospectiveSuccess(this.retrospectiveId);
}

class CreateRetrospectiveError extends CreateRetrospectiveState {
  final String message;

  CreateRetrospectiveError(this.message);
}
