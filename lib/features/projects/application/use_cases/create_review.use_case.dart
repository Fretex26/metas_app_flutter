import 'package:metas_app/features/projects/domain/entities/review.dart';
import 'package:metas_app/features/projects/domain/repositories/review.repository.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_review.dto.dart';

class CreateReviewUseCase {
  final ReviewRepository _repository;

  CreateReviewUseCase(this._repository);

  Future<Review> call(String sprintId, CreateReviewDto dto) async {
    return await _repository.createReview(sprintId, dto);
  }
}
