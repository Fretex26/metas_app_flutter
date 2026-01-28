import 'package:metas_app/features/projects/domain/entities/review.dart';
import 'package:metas_app/features/projects/domain/repositories/review.repository.dart';

class GetSprintReviewUseCase {
  final ReviewRepository _repository;

  GetSprintReviewUseCase(this._repository);

  Future<Review?> call(String sprintId) async {
    return await _repository.getSprintReview(sprintId);
  }
}
