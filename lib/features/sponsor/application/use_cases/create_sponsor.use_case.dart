import 'package:metas_app/features/sponsor/infrastructure/datasources/sponsor_datasource.dart';
import 'package:metas_app/features/sponsor/infrastructure/dto/create_sponsor.dto.dart';

/// Use case para crear una solicitud de patrocinador.
///
/// Se ejecuta durante el registro cuando el usuario elige ser sponsor.
/// El flujo completo es:
/// 1. Firebase Auth (crear usuario)
/// 2. POST /api/users con role: sponsor
/// 3. POST /api/sponsors (este use case)
///
/// El sponsor queda con estado **PENDING** hasta aprobación del administrador.
class CreateSponsorUseCase {
  final SponsorDatasource _datasource;

  /// Constructor del use case.
  ///
  /// [datasource] - Datasource opcional para inyección de dependencias (testing).
  CreateSponsorUseCase([SponsorDatasource? datasource])
      : _datasource = datasource ?? SponsorDatasource();

  /// Ejecuta el use case.
  ///
  /// [dto] - Datos del sponsor a crear.
  ///
  /// Lanza excepción si:
  /// - El usuario no está autenticado
  /// - El usuario no tiene role: sponsor
  /// - Ya existe una solicitud para este usuario
  /// - Error de red o del servidor
  Future<void> call(CreateSponsorDto dto) async {
    await _datasource.createSponsor(dto);
  }
}
