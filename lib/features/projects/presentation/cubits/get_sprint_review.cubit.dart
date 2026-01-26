import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/application/use_cases/get_sprint_review.use_case.dart';
import 'package:metas_app/features/projects/presentation/cubits/get_sprint_review.states.dart';

class GetSprintReviewCubit extends Cubit<GetSprintReviewState> {
  final GetSprintReviewUseCase _getSprintReviewUseCase;

  GetSprintReviewCubit({required GetSprintReviewUseCase getSprintReviewUseCase})
      : _getSprintReviewUseCase = getSprintReviewUseCase,
        super(GetSprintReviewInitial());

  Future<void> loadReview(String sprintId) async {
    emit(GetSprintReviewLoading());
    try {
      final review = await _getSprintReviewUseCase(sprintId);
      emit(GetSprintReviewLoaded(review));
    } catch (e) {
      emit(GetSprintReviewError(e.toString()));
    }
  }

  void refresh(String sprintId) {
    loadReview(sprintId);
  }
}
