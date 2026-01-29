import 'package:metas_app/features/sponsored_goals/domain/entities/sponsored_goal.dart';
import 'package:metas_app/features/sponsored_goals/domain/repositories/sponsored_goals.repository.dart';
import 'package:metas_app/features/sponsored_goals/infrastructure/dto/create_sponsored_goal.dto.dart';

/// Caso de uso para crear un nuevo Sponsored Goal.
/// 
/// Este caso de uso encapsula la lógica de negocio para crear un sponsored goal
/// desde el repositorio. Solo puede ser ejecutado por sponsors aprobados.
/// 
/// Validaciones del backend:
/// - El sponsor debe estar aprobado
/// - El proyecto debe pertenecer al sponsor
/// - El proyecto debe tener al menos una milestone
/// - Cada milestone debe tener al menos una task
/// - Las fechas deben ser válidas (endDate > startDate)
/// - maxUsers debe ser >= 1
class CreateSponsoredGoalUseCase {
  /// Repositorio de sponsored goals para acceder a los datos
  final SponsoredGoalsRepository _repository;

  /// Constructor del caso de uso
  /// 
  /// [repository] - Repositorio de sponsored goals inyectado
  CreateSponsoredGoalUseCase(this._repository);

  /// Ejecuta el caso de uso para crear un sponsored goal.
  /// 
  /// [dto] - Datos del sponsored goal a crear
  /// 
  /// Retorna el sponsored goal creado con su ID asignado.
  /// 
  /// Lanza una excepción si:
  /// - El usuario no es sponsor aprobado (403)
  /// - El proyecto no pertenece al sponsor (400)
  /// - Los datos son inválidos (400)
  /// - El usuario no está autenticado (401)
  Future<SponsoredGoal> call(CreateSponsoredGoalDto dto) async {
    return await _repository.createSponsoredGoal(dto);
  }
}
