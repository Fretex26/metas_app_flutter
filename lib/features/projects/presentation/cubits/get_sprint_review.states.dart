import 'package:metas_app/features/projects/domain/entities/review.dart';

abstract class GetSprintReviewState {}

class GetSprintReviewInitial extends GetSprintReviewState {}

class GetSprintReviewLoading extends GetSprintReviewState {}

class GetSprintReviewLoaded extends GetSprintReviewState {
  final Review? review;

  GetSprintReviewLoaded(this.review);
}

class GetSprintReviewError extends GetSprintReviewState {
  final String message;

  GetSprintReviewError(this.message);
}
