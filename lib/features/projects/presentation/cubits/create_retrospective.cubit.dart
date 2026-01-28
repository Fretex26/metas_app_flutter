import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/application/use_cases/create_retrospective.use_case.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_retrospective.dto.dart';
import 'package:metas_app/features/projects/presentation/cubits/create_retrospective.states.dart';

class CreateRetrospectiveCubit extends Cubit<CreateRetrospectiveState> {
  final CreateRetrospectiveUseCase _createRetrospectiveUseCase;

  CreateRetrospectiveCubit({required CreateRetrospectiveUseCase createRetrospectiveUseCase})
      : _createRetrospectiveUseCase = createRetrospectiveUseCase,
        super(CreateRetrospectiveInitial());

  Future<void> createRetrospective(String sprintId, CreateRetrospectiveDto dto) async {
    emit(CreateRetrospectiveLoading());
    try {
      final retrospective = await _createRetrospectiveUseCase(sprintId, dto);
      emit(CreateRetrospectiveSuccess(retrospective.id));
    } catch (e) {
      emit(CreateRetrospectiveError(e.toString()));
    }
  }
}
