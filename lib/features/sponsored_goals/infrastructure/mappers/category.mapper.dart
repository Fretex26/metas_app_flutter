import 'package:metas_app/features/sponsored_goals/domain/entities/category.dart';
import 'package:metas_app/features/sponsored_goals/infrastructure/dto/category_response.dto.dart';

/// Extensión para mapear [CategoryResponseDto] a la entidad de dominio [Category].
/// 
/// Convierte los datos recibidos del backend (DTO) a la entidad del dominio,
/// transformando strings de fecha a objetos DateTime.
extension CategoryResponseDtoMapper on CategoryResponseDto {
  /// Convierte el DTO de respuesta a una entidad Category del dominio.
  /// 
  /// Realiza las siguientes transformaciones:
  /// - Convierte strings de fecha (ISO format) a objetos DateTime
  /// 
  /// Retorna una instancia de [Category] con todos los datos mapeados.
  Category toDomain() {
    return Category(
      id: id,
      name: name,
      description: description,
      createdAt: DateTime.parse(createdAt),
    );
  }
}
