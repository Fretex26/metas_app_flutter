import 'package:metas_app/features/admin/domain/entities/admin_sponsor.dart';

/// Estados del cubit para gestión de sponsors por administradores.
abstract class AdminSponsorsState {}

/// Estado inicial (antes de cargar datos).
class AdminSponsorsInitial extends AdminSponsorsState {}

/// Estado de carga (solicitando datos al servidor).
class AdminSponsorsLoading extends AdminSponsorsState {}

/// Estado con datos cargados exitosamente.
///
/// Contiene:
/// - [pending]: Lista de sponsors pendientes de aprobación
/// - [all]: Lista de todos los sponsors (puede estar filtrada por [filterStatus])
/// - [filterStatus]: Estado de filtro aplicado (pending | approved | rejected | disabled | null para todos)
class AdminSponsorsLoaded extends AdminSponsorsState {
  final List<AdminSponsor> pending;
  final List<AdminSponsor> all;
  final String? filterStatus;

  AdminSponsorsLoaded({
    required this.pending,
    required this.all,
    this.filterStatus,
  });
}

/// Estado de error (fallo al cargar o ejecutar acción).
class AdminSponsorsError extends AdminSponsorsState {
  final String message;

  AdminSponsorsError(this.message);
}

/// Estado de éxito tras una acción (aprobar, rechazar, deshabilitar, habilitar).
///
/// Se emite después de una acción exitosa y antes de recargar los datos.
class AdminSponsorsActionSuccess extends AdminSponsorsState {
  final String message;

  AdminSponsorsActionSuccess(this.message);
}
