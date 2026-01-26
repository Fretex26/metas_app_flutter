abstract class CreateReviewState {}

class CreateReviewInitial extends CreateReviewState {}

class CreateReviewLoading extends CreateReviewState {}

class CreateReviewSuccess extends CreateReviewState {
  final String reviewId;

  CreateReviewSuccess(this.reviewId);
}

class CreateReviewError extends CreateReviewState {
  final String message;

  CreateReviewError(this.message);
}
