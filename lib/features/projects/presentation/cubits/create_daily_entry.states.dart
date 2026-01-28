/// Estados del cubit para crear una entrada diaria.
/// 
/// Define los diferentes estados que puede tener el proceso de creación
/// de una entrada diaria.
abstract class CreateDailyEntryState {}

/// Estado inicial del cubit (antes de intentar crear)
class CreateDailyEntryInitial extends CreateDailyEntryState {}

/// Estado de carga (mientras se está creando la entrada diaria)
class CreateDailyEntryLoading extends CreateDailyEntryState {}

/// Estado de éxito (cuando la entrada diaria se creó correctamente)
class CreateDailyEntrySuccess extends CreateDailyEntryState {
  /// ID de la entrada diaria creada
  final String dailyEntryId;

  CreateDailyEntrySuccess(this.dailyEntryId);
}

/// Estado de error (cuando ocurrió un error al crear la entrada diaria)
class CreateDailyEntryError extends CreateDailyEntryState {
  /// Mensaje de error
  final String message;

  CreateDailyEntryError(this.message);
}
