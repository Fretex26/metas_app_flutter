import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:metas_app/core/config/api_config.dart';
import 'package:metas_app/features/user/infrastructure/dto/user_response.dto.dart';

enum UserRole {
  user,
  sponsor,
  admin;

  String get value {
    switch (this) {
      case UserRole.user:
        return 'user';
      case UserRole.sponsor:
        return 'sponsor';
      case UserRole.admin:
        return 'admin';
    }
  }
}

class UserDatasource {
  final Dio _dio;

  UserDatasource({Dio? dio}) : _dio = dio ?? Dio();

  /// En Android, POST vía canal nativo (evita bloqueos de la pila HTTP de Dart).
  Future<({int statusCode, String body})?> _nativePost(
    String url,
    String token,
    Map<String, dynamic> data,
  ) async {
    if (!Platform.isAndroid) return null;
    const channel = MethodChannel('com.tfm.metas_app/auth_me');
    final result = await channel.invokeMethod<Map>('post', {
      'url': url,
      'token': token,
      'body': jsonEncode(data),
    }).timeout(
      const Duration(seconds: 25),
      onTimeout: () => throw DioException(
        requestOptions: RequestOptions(path: url),
        type: DioExceptionType.receiveTimeout,
        error: 'users timeout 25s (native)',
      ),
    );
    if (result == null) return null;
    return (statusCode: result['statusCode'] as int, body: (result['body'] as String?) ?? '');
  }

  /// Registra un usuario en la API después del registro en Firebase
  /// 
  /// [firebaseIdToken] - Token ID de Firebase obtenido después del registro
  /// [name] - Nombre del usuario (requerido)
  /// [email] - Email del usuario (requerido, formato email válido)
  /// [role] - Rol del usuario (opcional, por defecto "user")
  /// [categoryIds] - Array de UUIDs de categorías (opcional)
  /// 
  /// Retorna [UserResponseDto] con los datos del usuario registrado
  /// 
  /// Lanza [DioException] en caso de error:
  /// - 409 Conflict: El email o Firebase UID ya está registrado
  /// - 401 Unauthorized: Token inválido o expirado
  /// - 400 Bad Request: Datos de entrada inválidos
  Future<UserResponseDto> registerUserInApi({
    required String firebaseIdToken,
    required String name,
    required String email,
    UserRole? role,
    List<String>? categoryIds,
  }) async {
    try {
      final url = '${ApiConfig.baseUrl}/api/users';
      final payload = {
        'name': name,
        'email': email,
        if (role != null) 'role': role.value,
        if (categoryIds != null && categoryIds.isNotEmpty) 'categoryIds': categoryIds,
      };

      final native = await _nativePost(url, firebaseIdToken, payload);
      if (native != null) {
        final statusCode = native.statusCode;
        final rawBody = native.body;
        if (statusCode < 200 || statusCode >= 300) {
          dynamic responseData;
          try {
            responseData = jsonDecode(rawBody);
          } catch (_) {
            responseData = rawBody;
          }
          throw DioException(
            requestOptions: RequestOptions(path: url),
            response: Response(
              requestOptions: RequestOptions(path: url),
              statusCode: statusCode,
              data: responseData,
            ),
            type: DioExceptionType.badResponse,
            error: 'users $statusCode',
          );
        }
        return UserResponseDto.fromJson(jsonDecode(rawBody) as Map<String, dynamic>);
      }

      final response = await _dio.post(
        url,
        data: payload,
        options: Options(
          headers: {
            'Authorization': 'Bearer $firebaseIdToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      return UserResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      // Re-lanzar la excepción para que el repositorio pueda manejarla
      rethrow;
    } catch (e) {
      throw Exception('Error inesperado al registrar usuario en la API: $e');
    }
  }
}
