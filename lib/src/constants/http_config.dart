import 'package:dio/dio.dart';
import 'dart:io';
import 'package:exam1_software_movil/src/config/env_config.dart';
import 'package:exam1_software_movil/src/share_preferens/user_preferences.dart';
// final prefs = UserPreferences();

/// Configuration class for Dio HTTP client
class DioConfig {
  /// Get the base URL from environment variables
  static String get baseUrl => EnvConfig.apiBaseUrl;

  /// Get a configured Dio instance with proper settings
  static Dio get dio {
    final prefs = UserPreferences();
    final timeout = Duration(seconds: EnvConfig.apiTimeout);

    // Debug: Print token information
    print('Token available: ${prefs.token.isNotEmpty}');
    if (prefs.token.isNotEmpty) {
      print('Token value: ${prefs.token}');
    }

    final dioInstance = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
        if (prefs.token.isNotEmpty)
          // El backend espera el formato "token $token" exactamente
          HttpHeaders.authorizationHeader: 'token ${prefs.token}',
      },
      validateStatus: (status) {
        // Accept all responses (to handle errors manually)
        return true;
      },
    ));

    // Add request interceptor for logging
    dioInstance.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('REQUEST[${options.method}] => PATH: ${options.path}');
        print('Headers: ${options.headers}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print(
            'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print(
            'ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
        return handler.next(e);
      },
    ));

    return dioInstance;
  }

  /// Helper method for error handling
  static String handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'El tiempo de conexión se ha agotado. Por favor, intente nuevamente.';
      case DioExceptionType.badResponse:
        return _handleErrorResponse(error.response);
      case DioExceptionType.cancel:
        return 'La solicitud fue cancelada';
      case DioExceptionType.connectionError:
        return 'Error de conexión. Verifique su conexión a Internet.';
      default:
        return 'Ocurrió un error inesperado: ${error.message}';
    }
  }

  static String _handleErrorResponse(Response? response) {
    if (response == null) {
      return 'No se recibió respuesta del servidor';
    }

    try {
      print('Error response data: ${response.data}');
      print('Error status code: ${response.statusCode}');

      if (response.data is Map && response.data.containsKey('detail')) {
        return response.data['detail'];
      }
      return 'Error del servidor: ${response.statusCode}';
    } catch (e) {
      return 'Error al procesar la respuesta del servidor';
    }
  }
}
