import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/application/use_cases/get_sprint_retrospective.use_case.dart';
import 'package:metas_app/features/projects/presentation/cubits/get_sprint_retrospective.states.dart';

class GetSprintRetrospectiveCubit extends Cubit<GetSprintRetrospectiveState> {
  final GetSprintRetrospectiveUseCase _getSprintRetrospectiveUseCase;

  GetSprintRetrospectiveCubit(
      {required GetSprintRetrospectiveUseCase getSprintRetrospectiveUseCase})
      : _getSprintRetrospectiveUseCase = getSprintRetrospectiveUseCase,
        super(GetSprintRetrospectiveInitial());

  Future<void> loadRetrospective(String sprintId) async {
    emit(GetSprintRetrospectiveLoading());
    try {
      final retrospective = await _getSprintRetrospectiveUseCase(sprintId);
      emit(GetSprintRetrospectiveLoaded(retrospective));
    } catch (e) {
      emit(GetSprintRetrospectiveError(e.toString()));
    }
  }

  void refresh(String sprintId) {
    loadRetrospective(sprintId);
  }
}
