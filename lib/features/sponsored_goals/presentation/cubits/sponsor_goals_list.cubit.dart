import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/sponsored_goals/application/use_cases/get_my_sponsored_goals.use_case.dart';
import 'package:metas_app/features/sponsored_goals/presentation/cubits/sponsor_goals_list.states.dart';

class SponsorGoalsListCubit extends Cubit<SponsorGoalsListState> {
  final GetMySponsoredGoalsUseCase _getMySponsoredGoalsUseCase;

  SponsorGoalsListCubit({
    required GetMySponsoredGoalsUseCase getMySponsoredGoalsUseCase,
  })  : _getMySponsoredGoalsUseCase = getMySponsoredGoalsUseCase,
        super(SponsorGoalsListInitial());

  Future<void> loadGoals() async {
    emit(SponsorGoalsListLoading());
    try {
      final goals = await _getMySponsoredGoalsUseCase();
      emit(SponsorGoalsListLoaded(goals: goals));
    } catch (e) {
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      emit(SponsorGoalsListError(msg));
    }
  }
}
