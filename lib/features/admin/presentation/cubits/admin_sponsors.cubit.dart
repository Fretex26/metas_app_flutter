import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/admin/application/use_cases/admin_sponsors.use_cases.dart';
import 'package:metas_app/features/admin/domain/entities/admin_sponsor.dart';
import 'package:metas_app/features/admin/presentation/cubits/admin_sponsors.states.dart';

/// Cubit para gestionar el estado de la lista de sponsors en el portal de administración.
///
/// Maneja:
/// - Carga de sponsors pendientes y todos los sponsors (con filtro opcional)
/// - Aprobación, rechazo, deshabilitación y habilitación de sponsors
/// - Recarga automática tras acciones exitosas
///
/// Solo accesible para usuarios con rol **admin**.
class AdminSponsorsCubit extends Cubit<AdminSponsorsState> {
  final GetAdminPendingSponsorsUseCase getPending;
  final GetAdminAllSponsorsUseCase getAll;
  final AdminApproveSponsorUseCase approveUseCase;
  final AdminRejectSponsorUseCase rejectUseCase;
  final AdminDisableSponsorUseCase disableUseCase;
  final AdminEnableSponsorUseCase enableUseCase;

  /// Último filtro de estado aplicado (para recargar después de acciones).
  String? _lastFilterStatus;

  /// Constructor del cubit.
  ///
  /// Requiere todos los use cases necesarios para las operaciones de administración.
  AdminSponsorsCubit({
    required this.getPending,
    required this.getAll,
    required this.approveUseCase,
    required this.rejectUseCase,
    required this.disableUseCase,
    required this.enableUseCase,
  }) : super(AdminSponsorsInitial());

  /// Carga los sponsors pendientes y todos los sponsors (opcionalmente filtrados).
  ///
  /// [status] - Filtro opcional para la lista "todos": `pending` | `approved` | `rejected` | `disabled`.
  /// Si es `null`, retorna todos los sponsors sin filtrar.
  ///
  /// Emite:
  /// - [AdminSponsorsLoading] mientras carga
  /// - [AdminSponsorsLoaded] con las listas de pendientes y todos
  /// - [AdminSponsorsError] si ocurre un error
  Future<void> load({String? status}) async {
    _lastFilterStatus = status;
    emit(AdminSponsorsLoading());
    try {
      final pending = await getPending();
      final all = await getAll(status: status);
      emit(AdminSponsorsLoaded(
        pending: pending,
        all: all,
        filterStatus: status,
      ));
    } catch (e) {
      emit(AdminSponsorsError(e.toString()));
    }
  }

  /// Recarga los datos usando el último filtro aplicado.
  Future<void> _reload() => load(status: _lastFilterStatus);

  /// Aprueba un sponsor (PENDING → APPROVED).
  ///
  /// [s] - Sponsor a aprobar.
  ///
  /// Emite:
  /// - [AdminSponsorsActionSuccess] con mensaje de éxito
  /// - Recarga automáticamente los datos
  /// - [AdminSponsorsError] si ocurre un error
  Future<void> approve(AdminSponsor s) async {
    try {
      await approveUseCase(s.id);
      emit(AdminSponsorsActionSuccess('Sponsor aprobado'));
      await _reload();
    } catch (e) {
      emit(AdminSponsorsError(e.toString()));
    }
  }

  /// Rechaza un sponsor (PENDING → REJECTED).
  ///
  /// [s] - Sponsor a rechazar.
  /// [reason] - Motivo del rechazo (opcional).
  ///
  /// Emite:
  /// - [AdminSponsorsActionSuccess] con mensaje de éxito
  /// - Recarga automáticamente los datos
  /// - [AdminSponsorsError] si ocurre un error
  Future<void> reject(AdminSponsor s, {String? reason}) async {
    try {
      await rejectUseCase(s.id, rejectionReason: reason);
      emit(AdminSponsorsActionSuccess('Sponsor rechazado'));
      await _reload();
    } catch (e) {
      emit(AdminSponsorsError(e.toString()));
    }
  }

  /// Deshabilita un sponsor (APPROVED → DISABLED).
  ///
  /// [s] - Sponsor a deshabilitar.
  ///
  /// Emite:
  /// - [AdminSponsorsActionSuccess] con mensaje de éxito
  /// - Recarga automáticamente los datos
  /// - [AdminSponsorsError] si ocurre un error
  Future<void> disable(AdminSponsor s) async {
    try {
      await disableUseCase(s.id);
      emit(AdminSponsorsActionSuccess('Sponsor deshabilitado'));
      await _reload();
    } catch (e) {
      emit(AdminSponsorsError(e.toString()));
    }
  }

  /// Habilita un sponsor (DISABLED → APPROVED).
  ///
  /// [s] - Sponsor a habilitar.
  ///
  /// Emite:
  /// - [AdminSponsorsActionSuccess] con mensaje de éxito
  /// - Recarga automáticamente los datos
  /// - [AdminSponsorsError] si ocurre un error
  Future<void> enable(AdminSponsor s) async {
    try {
      await enableUseCase(s.id);
      emit(AdminSponsorsActionSuccess('Sponsor habilitado'));
      await _reload();
    } catch (e) {
      emit(AdminSponsorsError(e.toString()));
    }
  }
}
