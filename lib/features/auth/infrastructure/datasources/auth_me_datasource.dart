import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:metas_app/core/config/api_config.dart';
import 'package:metas_app/features/auth/infrastructure/dto/auth_me_response.dto.dart';

/// Entrada del isolate: hace GET auth/me y envía [statusCode, body] al SendPort.
void _isolateAuthMeEntry(SendPort mainSendPort) {
  final port = ReceivePort();
  mainSendPort.send(port.sendPort);
  port.listen((dynamic message) async {
    if (message is! List || message.length != 2) return;
    final url = message[0] as String;
    final token = message[1] as String;
    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Connection': 'close',
              'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36',
            },
          )
          .timeout(const Duration(seconds: 15));
      mainSendPort.send([response.statusCode, response.body]);
    } catch (e) {
      mainSendPort.send(['error', e.toString()]);
    }
  });
}

/// Datasource para [GET /api/auth/me].
///
/// Devuelve user + sponsor (si aplica) para redirección y control de acceso.
class AuthMeDatasource {
  final Dio _dio;

  AuthMeDatasource({Dio? dio}) : _dio = dio ?? Dio();

  Future<String> _getAuthToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    final token = await user.getIdToken();
    if (token == null) throw Exception('No se pudo obtener el token');
    return token;
  }

  /// Obtiene la sesión actual del usuario autenticado.
  ///
  /// Endpoint: GET /api/auth/me
  ///
  /// Retorna [AuthMeResponseDto] con datos del usuario y sponsor (si aplica).
  ///
  /// Lanza [DioException] si:
  /// - El usuario no está autenticado (401)
  /// - El usuario no existe en la base de datos (401)
  /// - Error de red o del servidor
  Future<AuthMeResponseDto> getAuthMe() async {
    final token = await _getAuthToken();
    final url = '${ApiConfig.baseUrl}/api/auth/me';
    const maxAttempts = 2;
    DioException? lastTimeout;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        if (attempt > 1) {
          await Future<void>.delayed(const Duration(seconds: 3));
        }
        if (Platform.isAndroid) {
          try {
            final dto = await _getAuthMeViaNative(url: url, token: token);
            if (dto != null) return dto;
          } on DioException {
            rethrow;
          } catch (_) {
            // Fallback a isolate en Android si el canal nativo falla
          }
        }
        final dto = await _getAuthMeViaIsolate(url: url, token: token);
        return dto;
      } on DioException catch (e) {
        lastTimeout = e;
        if (e.response?.statusCode == 401) {
          throw DioException(
            requestOptions: e.requestOptions,
            response: e.response,
            type: e.type,
            error: 'Usuario no encontrado en el sistema',
          );
        }
        if (attempt >= maxAttempts) {
          throw DioException(
            requestOptions: e.requestOptions,
            type: DioExceptionType.receiveTimeout,
            error: 'No se pudo conectar al servidor. Comprueba tu conexión e intenta de nuevo.',
          );
        }
      } catch (e) {
        if (e is DioException) rethrow;
        rethrow;
      }
    }
    throw lastTimeout ?? DioException(
      requestOptions: RequestOptions(path: url),
      type: DioExceptionType.receiveTimeout,
      error: 'No se pudo conectar al servidor. Comprueba tu conexión e intenta de nuevo.',
    );
  }

  /// En Android, usa HttpURLConnection nativo (evita bloqueos de la pila HTTP de Dart en algunos dispositivos).
  Future<AuthMeResponseDto?> _getAuthMeViaNative({required String url, required String token}) async {
    const channel = MethodChannel('com.tfm.metas_app/auth_me');
    final result = await channel.invokeMethod<Map>('getAuthMe', {'url': url, 'token': token}).timeout(
      const Duration(seconds: 25),
      onTimeout: () => throw DioException(
        requestOptions: RequestOptions(path: url),
        type: DioExceptionType.receiveTimeout,
        error: 'auth/me timeout 25s (native)',
      ),
    );
    if (result == null) return null;
    final statusCode = result['statusCode'] as int;
    final body = (result['body'] as String?) ?? '';
    if (statusCode == 401) {
      throw DioException(
        requestOptions: RequestOptions(path: url),
        response: Response(requestOptions: RequestOptions(path: url), statusCode: 401, data: body),
        type: DioExceptionType.badResponse,
        error: 'Usuario no encontrado en el sistema',
      );
    }
    if (statusCode != 200) {
      throw DioException(
        requestOptions: RequestOptions(path: url),
        response: Response(requestOptions: RequestOptions(path: url), statusCode: statusCode, data: body),
        type: DioExceptionType.badResponse,
        error: 'auth/me $statusCode',
      );
    }
    final data = jsonDecode(body) as Map<String, dynamic>;
    return AuthMeResponseDto.fromJson(data);
  }

  Future<AuthMeResponseDto> _getAuthMeViaIsolate({required String url, required String token}) async {
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(_isolateAuthMeEntry, receivePort.sendPort);
    SendPort? isolateSendPort;
    dynamic result;
    final completer = Completer<void>();
    receivePort.listen((dynamic message) {
      if (isolateSendPort == null) {
        isolateSendPort = message as SendPort;
        isolateSendPort!.send([url, token]);
      } else {
        result = message;
        if (!completer.isCompleted) completer.complete();
      }
    });
    await completer.future.timeout(const Duration(seconds: 25), onTimeout: () {
      isolate.kill(priority: Isolate.immediate);
      throw DioException(
        requestOptions: RequestOptions(path: url),
        type: DioExceptionType.receiveTimeout,
        error: 'auth/me timeout 25s (isolate)',
      );
    });
    isolate.kill(priority: Isolate.immediate);

    if (result is List && result.length >= 2) {
      if (result[0] == 'error') {
        throw Exception(result[1] as String);
      }
      final statusCode = result[0] as int;
      final body = result[1] as String;
      if (statusCode == 401) {
        throw DioException(
          requestOptions: RequestOptions(path: url),
          response: Response(
            requestOptions: RequestOptions(path: url),
            statusCode: 401,
            data: body,
          ),
          type: DioExceptionType.badResponse,
          error: 'Usuario no encontrado en el sistema',
        );
      }
      if (statusCode != 200) {
        throw DioException(
          requestOptions: RequestOptions(path: url),
          response: Response(
            requestOptions: RequestOptions(path: url),
            statusCode: statusCode,
            data: body,
          ),
          type: DioExceptionType.badResponse,
          error: 'auth/me $statusCode',
        );
      }
      final data = jsonDecode(body) as Map<String, dynamic>;
      return AuthMeResponseDto.fromJson(data);
    }
    throw Exception('Respuesta inesperada del isolate: $result');
  }
}
