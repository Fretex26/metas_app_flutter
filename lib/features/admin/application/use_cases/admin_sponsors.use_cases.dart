import 'package:metas_app/features/admin/domain/entities/admin_sponsor.dart';
import 'package:metas_app/features/admin/infrastructure/datasources/admin_sponsors_datasource.dart';
import 'package:metas_app/features/admin/infrastructure/mappers/admin_sponsor.mapper.dart';

/// Use case para obtener la lista de sponsors pendientes de aprobación.
///
/// Equivalente a [GET /api/admin/sponsors/pending].
/// Solo accesible para usuarios con rol **admin**.
class GetAdminPendingSponsorsUseCase {
  final AdminSponsorsDatasource _ds;

  /// Constructor del use case.
  ///
  /// [ds] - Datasource opcional para inyección de dependencias (testing).
  GetAdminPendingSponsorsUseCase([AdminSponsorsDatasource? ds])
      : _ds = ds ?? AdminSponsorsDatasource();

  /// Ejecuta el use case.
  ///
  /// Retorna lista de sponsors con estado **PENDING**.
  ///
  /// Lanza excepción si:
  /// - El usuario no está autenticado
  /// - El usuario no tiene rol admin
  /// - Error de red o del servidor
  Future<List<AdminSponsor>> call() async {
    final list = await _ds.getPending();
    return list.map((e) => e.toDomain()).toList();
  }
}

/// Use case para obtener la lista de todos los sponsors (opcionalmente filtrada).
///
/// Equivalente a [GET /api/admin/sponsors?status=...].
/// Solo accesible para usuarios con rol **admin**.
class GetAdminAllSponsorsUseCase {
  final AdminSponsorsDatasource _ds;

  /// Constructor del use case.
  ///
  /// [ds] - Datasource opcional para inyección de dependencias (testing).
  GetAdminAllSponsorsUseCase([AdminSponsorsDatasource? ds])
      : _ds = ds ?? AdminSponsorsDatasource();

  /// Ejecuta el use case.
  ///
  /// [status] - Filtro opcional: `pending` | `approved` | `rejected` | `disabled`.
  /// Si es `null`, retorna todos los sponsors.
  ///
  /// Retorna lista de sponsors según el filtro aplicado.
  ///
  /// Lanza excepción si:
  /// - El usuario no está autenticado
  /// - El usuario no tiene rol admin
  /// - Error de red o del servidor
  Future<List<AdminSponsor>> call({String? status}) async {
    final list = await _ds.getAll(status: status);
    return list.map((e) => e.toDomain()).toList();
  }
}

/// Use case para obtener el detalle de un sponsor específico.
///
/// Equivalente a [GET /api/admin/sponsors/:id].
/// Solo accesible para usuarios con rol **admin**.
class GetAdminSponsorByIdUseCase {
  final AdminSponsorsDatasource _ds;

  /// Constructor del use case.
  ///
  /// [ds] - Datasource opcional para inyección de dependencias (testing).
  GetAdminSponsorByIdUseCase([AdminSponsorsDatasource? ds])
      : _ds = ds ?? AdminSponsorsDatasource();

  /// Ejecuta el use case.
  ///
  /// [sponsorId] - Identificador único del sponsor (UUID).
  ///
  /// Retorna el sponsor con todos sus datos.
  ///
  /// Lanza excepción si:
  /// - El usuario no está autenticado
  /// - El usuario no tiene rol admin
  /// - El sponsor no existe
  /// - Error de red o del servidor
  Future<AdminSponsor> call(String sponsorId) async {
    final dto = await _ds.getById(sponsorId);
    return dto.toDomain();
  }
}

/// Use case para aprobar un sponsor (PENDING → APPROVED).
///
/// Equivalente a [POST /api/admin/sponsors/:id/approve].
/// Solo accesible para usuarios con rol **admin**.
class AdminApproveSponsorUseCase {
  final AdminSponsorsDatasource _ds;

  /// Constructor del use case.
  ///
  /// [ds] - Datasource opcional para inyección de dependencias (testing).
  AdminApproveSponsorUseCase([AdminSponsorsDatasource? ds])
      : _ds = ds ?? AdminSponsorsDatasource();

  /// Ejecuta el use case.
  ///
  /// [sponsorId] - Identificador único del sponsor a aprobar.
  ///
  /// Solo funciona si el sponsor está en estado **PENDING**.
  ///
  /// Lanza excepción si:
  /// - El usuario no está autenticado
  /// - El usuario no tiene rol admin
  /// - El sponsor no está en estado PENDING
  /// - Error de red o del servidor
  Future<void> call(String sponsorId) => _ds.approve(sponsorId);
}

/// Use case para rechazar un sponsor (PENDING → REJECTED).
///
/// Equivalente a [POST /api/admin/sponsors/:id/reject].
/// Solo accesible para usuarios con rol **admin**.
class AdminRejectSponsorUseCase {
  final AdminSponsorsDatasource _ds;

  /// Constructor del use case.
  ///
  /// [ds] - Datasource opcional para inyección de dependencias (testing).
  AdminRejectSponsorUseCase([AdminSponsorsDatasource? ds])
      : _ds = ds ?? AdminSponsorsDatasource();

  /// Ejecuta el use case.
  ///
  /// [sponsorId] - Identificador único del sponsor a rechazar.
  /// [rejectionReason] - Motivo del rechazo (opcional).
  ///
  /// Solo funciona si el sponsor está en estado **PENDING**.
  ///
  /// Lanza excepción si:
  /// - El usuario no está autenticado
  /// - El usuario no tiene rol admin
  /// - El sponsor no está en estado PENDING
  /// - Error de red o del servidor
  Future<void> call(String sponsorId, {String? rejectionReason}) =>
      _ds.reject(sponsorId, rejectionReason: rejectionReason);
}

/// Use case para deshabilitar un sponsor (APPROVED → DISABLED).
///
/// Equivalente a [POST /api/admin/sponsors/:id/disable].
/// Solo accesible para usuarios con rol **admin**.
class AdminDisableSponsorUseCase {
  final AdminSponsorsDatasource _ds;

  /// Constructor del use case.
  ///
  /// [ds] - Datasource opcional para inyección de dependencias (testing).
  AdminDisableSponsorUseCase([AdminSponsorsDatasource? ds])
      : _ds = ds ?? AdminSponsorsDatasource();

  /// Ejecuta el use case.
  ///
  /// [sponsorId] - Identificador único del sponsor a deshabilitar.
  ///
  /// Solo funciona si el sponsor está en estado **APPROVED**.
  ///
  /// Lanza excepción si:
  /// - El usuario no está autenticado
  /// - El usuario no tiene rol admin
  /// - El sponsor no está en estado APPROVED
  /// - Error de red o del servidor
  Future<void> call(String sponsorId) => _ds.disable(sponsorId);
}

/// Use case para habilitar un sponsor (DISABLED → APPROVED).
///
/// Equivalente a [POST /api/admin/sponsors/:id/enable].
/// Solo accesible para usuarios con rol **admin**.
class AdminEnableSponsorUseCase {
  final AdminSponsorsDatasource _ds;

  /// Constructor del use case.
  ///
  /// [ds] - Datasource opcional para inyección de dependencias (testing).
  AdminEnableSponsorUseCase([AdminSponsorsDatasource? ds])
      : _ds = ds ?? AdminSponsorsDatasource();

  /// Ejecuta el use case.
  ///
  /// [sponsorId] - Identificador único del sponsor a habilitar.
  ///
  /// Solo funciona si el sponsor está en estado **DISABLED**.
  ///
  /// Lanza excepción si:
  /// - El usuario no está autenticado
  /// - El usuario no tiene rol admin
  /// - El sponsor no está en estado DISABLED
  /// - Error de red o del servidor
  Future<void> call(String sponsorId) => _ds.enable(sponsorId);
}
