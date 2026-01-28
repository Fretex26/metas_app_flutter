import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/application/use_cases/create_review.use_case.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_review.dto.dart';
import 'package:metas_app/features/projects/presentation/cubits/create_review.states.dart';

class CreateReviewCubit extends Cubit<CreateReviewState> {
  final CreateReviewUseCase _createReviewUseCase;

  CreateReviewCubit({required CreateReviewUseCase createReviewUseCase})
      : _createReviewUseCase = createReviewUseCase,
        super(CreateReviewInitial());

  Future<void> createReview(String sprintId, CreateReviewDto dto) async {
    emit(CreateReviewLoading());
    try {
      final review = await _createReviewUseCase(sprintId, dto);
      emit(CreateReviewSuccess(review.id));
    } catch (e) {
      emit(CreateReviewError(e.toString()));
    }
  }
}
