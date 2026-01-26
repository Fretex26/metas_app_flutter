import 'package:metas_app/features/projects/domain/entities/pending_sprint.dart';

abstract class PendingSprintsState {}

class PendingSprintsInitial extends PendingSprintsState {}

class PendingSprintsLoading extends PendingSprintsState {}

class PendingSprintsLoaded extends PendingSprintsState {
  final List<PendingSprint> pendingSprints;

  PendingSprintsLoaded(this.pendingSprints);
}

class PendingSprintsError extends PendingSprintsState {
  final String message;

  PendingSprintsError(this.message);
}
