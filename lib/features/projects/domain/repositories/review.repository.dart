import 'package:metas_app/features/projects/domain/entities/review.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_review.dto.dart';

/// Interfaz del repositorio para operaciones relacionadas con reviews.
/// 
/// Define los contratos para obtener y crear reviews dentro de sprints.
/// Esta interfaz es implementada por [ReviewRepositoryImpl] en la capa de infraestructura.
abstract class ReviewRepository {
  /// Obtiene la review asociada a un sprint específico.
  /// 
  /// [sprintId] - Identificador único del sprint (UUID)
  /// 
  /// Retorna la review si existe y el usuario tiene permisos, o null si no existe.
  /// 
  /// Lanza una excepción si:
  /// - El sprint no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<Review?> getSprintReview(String sprintId);

  /// Crea una nueva review para un sprint.
  /// 
  /// [sprintId] - Identificador único del sprint (UUID)
  /// [dto] - Datos de la review a crear
  /// 
  /// Retorna la review creada con su ID asignado y el porcentaje de progreso calculado.
  /// 
  /// Lanza una excepción si:
  /// - El sprint no existe o no pertenece al usuario (404)
  /// - Ya existe una review para este sprint (409)
  /// - Los datos son inválidos (400)
  /// - El usuario no está autenticado (401)
  Future<Review> createReview(String sprintId, CreateReviewDto dto);
}
