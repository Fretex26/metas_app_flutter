import 'package:metas_app/features/projects/domain/entities/retrospective.dart';
import 'package:metas_app/features/projects/infrastructure/dto/create_retrospective.dto.dart';

/// Interfaz del repositorio para operaciones relacionadas con retrospectivas.
/// 
/// Define los contratos para obtener y crear retrospectivas dentro de sprints.
/// Esta interfaz es implementada por [RetrospectiveRepositoryImpl] en la capa de infraestructura.
abstract class RetrospectiveRepository {
  /// Obtiene la retrospectiva asociada a un sprint específico.
  /// 
  /// [sprintId] - Identificador único del sprint (UUID)
  /// 
  /// Retorna la retrospectiva si existe y el usuario tiene permisos, o null si no existe.
  /// Si es pública, cualquiera puede verla. Si es privada, solo el dueño puede verla.
  /// 
  /// Lanza una excepción si:
  /// - El sprint no existe (404)
  /// - El usuario no tiene permisos (403) - solo aplica si es privada y no eres el dueño
  /// - El usuario no está autenticado (401)
  Future<Retrospective?> getSprintRetrospective(String sprintId);

  /// Crea una nueva retrospectiva para un sprint.
  /// 
  /// [sprintId] - Identificador único del sprint (UUID)
  /// [dto] - Datos de la retrospectiva a crear
  /// 
  /// Retorna la retrospectiva creada con su ID asignado.
  /// 
  /// Lanza una excepción si:
  /// - El sprint no existe o no pertenece al usuario (404)
  /// - Ya existe una retrospectiva para este sprint (409)
  /// - Los datos son inválidos (400)
  /// - El usuario no está autenticado (401)
  Future<Retrospective> createRetrospective(String sprintId, CreateRetrospectiveDto dto);

  /// Obtiene todas las retrospectivas públicas disponibles.
  /// 
  /// Retorna una lista de retrospectivas marcadas como públicas.
  /// 
  /// Lanza una excepción si:
  /// - El usuario no está autenticado (401)
  Future<List<Retrospective>> getPublicRetrospectives();
}
