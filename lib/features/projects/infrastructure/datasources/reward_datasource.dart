import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:metas_app/core/config/api_config.dart';
import 'package:metas_app/features/projects/infrastructure/dto/reward_response.dto.dart';

/// Datasource para realizar operaciones HTTP relacionadas con rewards (recompensas).
/// 
/// Implementa las llamadas a la API del backend usando Dio y maneja la autenticación
/// mediante tokens de Firebase. Todas las peticiones incluyen el header de autorización.
class RewardDatasource {
  /// Cliente HTTP para realizar las peticiones
  final Dio _dio;

  /// Constructor del datasource
  /// 
  /// [dio] - Cliente Dio opcional para inyección de dependencias (útil para testing)
  RewardDatasource({Dio? dio}) : _dio = dio ?? Dio();

  /// Obtiene el token de autenticación de Firebase del usuario actual.
  /// 
  /// Retorna el token ID de Firebase necesario para autenticar las peticiones.
  /// 
  /// Lanza una excepción si:
  /// - El usuario no está autenticado
  /// - No se puede obtener el token
  Future<String> _getAuthToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }
    final token = await user.getIdToken();
    if (token == null) {
      throw Exception('No se pudo obtener el token de autenticación');
    }
    return token;
  }

  /// Obtiene una recompensa específica por su ID.
  /// 
  /// Endpoint: GET /api/rewards/:id
  /// 
  /// [id] - Identificador único de la recompensa (UUID)
  /// 
  /// Retorna la recompensa si existe y el usuario tiene permisos.
  /// 
  /// Lanza una excepción si:
  /// - La recompensa no existe (404)
  /// - El usuario no tiene permisos (403)
  /// - El usuario no está autenticado (401)
  Future<RewardResponseDto> getRewardById(String id) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/rewards/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return RewardResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Recompensa no encontrada');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('No tienes permiso para acceder a esta recompensa');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al obtener recompensa: $e');
    }
  }

  /// Obtiene todas las recompensas del usuario autenticado.
  /// 
  /// Endpoint: GET /api/rewards
  /// 
  /// Retorna una lista de todas las recompensas asociadas a los proyectos
  /// y milestones del usuario actual.
  /// 
  /// Lanza una excepción si:
  /// - El usuario no está autenticado (401)
  /// - Hay un error de red o del servidor
  Future<List<RewardResponseDto>> getUserRewards() async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/rewards',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => RewardResponseDto.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error al obtener recompensas: $e');
    }
  }
}
