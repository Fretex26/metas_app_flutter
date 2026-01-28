import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:metas_app/core/config/api_config.dart';
import 'package:metas_app/features/sponsor/infrastructure/dto/create_sponsor.dto.dart';

/// Datasource para operaciones HTTP relacionadas con sponsors.
///
/// Implementa las llamadas a la API del backend usando Dio y maneja la autenticación
/// mediante tokens de Firebase. Todas las peticiones incluyen el header de autorización.
class SponsorDatasource {
  final Dio _dio;

  /// Constructor del datasource.
  ///
  /// [dio] - Cliente Dio opcional para inyección de dependencias (útil para testing).
  SponsorDatasource({Dio? dio}) : _dio = dio ?? Dio();

  /// Obtiene el token de autenticación de Firebase del usuario actual.
  ///
  /// Retorna el token ID de Firebase necesario para autenticar las peticiones.
  ///
  /// Lanza una excepción si:
  /// - El usuario no está autenticado
  /// - No se puede obtener el token
  Future<String> _getAuthToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    final token = await user.getIdToken();
    if (token == null) throw Exception('No se pudo obtener el token');
    return token;
  }

  /// Crea una solicitud de patrocinador.
  ///
  /// Endpoint: POST /api/sponsors
  ///
  /// Se llama después de registrar un usuario con `role: sponsor` en [POST /api/users].
  /// El sponsor queda con estado **PENDING** hasta que un administrador lo apruebe.
  ///
  /// [dto] - Datos del sponsor: businessName, description, category, contactEmail, logoUrl (opcional).
  ///
  /// Lanza una excepción si:
  /// - El usuario no está autenticado (401)
  /// - El usuario no tiene `role: sponsor` (403)
  /// - Ya existe una solicitud para este usuario (409)
  /// - Error de red o del servidor
  Future<void> createSponsor(CreateSponsorDto dto) async {
    final token = await _getAuthToken();
    await _dio.post(
      '${ApiConfig.baseUrl}/api/sponsors',
      data: dto.toJson(),
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
  }
}
