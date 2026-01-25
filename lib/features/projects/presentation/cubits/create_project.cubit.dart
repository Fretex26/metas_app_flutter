import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/application/use_cases/create_project.use_case.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_project.dto.dart';
import 'package:metas_app/features/projects/presentation/cubits/create_project.states.dart';

/// Cubit para gestionar el estado de creación de proyectos.
/// 
/// Maneja el flujo de creación de un nuevo proyecto, emitiendo estados
/// de carga, éxito y error para que la UI pueda reaccionar apropiadamente.
class CreateProjectCubit extends Cubit<CreateProjectState> {
  /// Caso de uso para crear proyectos
  final CreateProjectUseCase _createProjectUseCase;

  /// Constructor del cubit
  /// 
  /// [createProjectUseCase] - Caso de uso para crear proyectos inyectado
  CreateProjectCubit({required CreateProjectUseCase createProjectUseCase})
      : _createProjectUseCase = createProjectUseCase,
        super(CreateProjectInitial());

  /// Crea un nuevo proyecto con los datos proporcionados.
  /// 
  /// [dto] - Datos del proyecto a crear, incluyendo la recompensa obligatoria
  /// 
  /// Emite:
  /// - [CreateProjectLoading] mientras se crea
  /// - [CreateProjectSuccess] con el ID del proyecto creado
  /// - [CreateProjectError] si hay un error (ej: límite de 6 proyectos activos)
  Future<void> createProject(CreateProjectDto dto) async {
    emit(CreateProjectLoading());
    try {
      final project = await _createProjectUseCase(dto);
      emit(CreateProjectSuccess(project.id));
    } catch (e) {
      emit(CreateProjectError(e.toString()));
    }
  }
}
