import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:exam1_software_movil/src/constants/http_config.dart';
import 'package:exam1_software_movil/src/share_preferens/user_preferences.dart';

/// Modelo de respuesta para la autenticación
class AuthResponse {
  final String token;
  final int userId;
  final String? email;
  final String? nombreCompleto;

  AuthResponse({
    required this.token,
    required this.userId,
    this.email,
    this.nombreCompleto,
  });
}

/// Servicio para gestionar autenticación
class AuthService {
  /// Realiza el login del usuario
  Future<AuthResponse?> login(String username, String password) async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? tokenMovil = await messaging.getToken();
      print('AuthService: Token de dispositivo: $tokenMovil');

      Map<String, dynamic> body = {
        'username': username,
        'password': password,
        // 'tokenMovil': tokenMovil
      };

      final dio = DioConfig.dio;

      print(
          'AuthService: Enviando solicitud a ${dio.options.baseUrl}/Libreria/login/');
      print('AuthService: Cuerpo de la solicitud: $body');

      final response = await dio.post('/Libreria/login/', data: body);

      print('AuthService: Código de estado: ${response.statusCode}');
      print('AuthService: Tipo de respuesta: ${response.data.runtimeType}');

      // Manejar diferentes tipos de respuesta
      if (response.data is Map<String, dynamic>) {
        final Map<String, dynamic> dataMap = response.data;
        print('AuthService: dataMap: $dataMap');

        if (dataMap.containsKey('token')) {
          print('AuthService: TOKEN RECIBIDO: ${dataMap['token']}');

          return AuthResponse(
            token: dataMap['token'],
            userId: dataMap['user_id'] ?? 0,
            email: username, // Usar el email proporcionado por el usuario
          );
        } else {
          print('AuthService: NO SE RECIBIÓ TOKEN EN LA RESPUESTA');
          throw Exception('No se recibió token en la respuesta');
        }
      } else if (response.data is String) {
        print('AuthService: Respuesta como string: ${response.data}');

        // Intentar parsear si es JSON
        try {
          final parsedData = json.decode(response.data);
          print('AuthService: Respuesta parseada: $parsedData');

          if (parsedData is Map && parsedData.containsKey('token')) {
            return AuthResponse(
              token: parsedData['token'],
              userId: parsedData['user_id'] ?? 0,
              email: username,
            );
          }
        } catch (e) {
          print('AuthService: La respuesta no es JSON válido');
        }
      }

      throw Exception('Error al iniciar sesión');
    } catch (e) {
      print('AuthService: Error en login: $e');
      // Si es un DioException, podemos obtener más detalles
      if (e is DioException) {
        print('AuthService: DioError código: ${e.response?.statusCode}');
        print('AuthService: DioError respuesta: ${e.response?.data}');
        throw _handleDioError(e);
      }

      throw Exception('Error en la autenticación: $e');
    }
  }

  /// Registra un nuevo usuario
  Future<AuthResponse?> register({
    required String email,
    required String password,
    required String nombreCompleto,
    required String telefono,
    required String direccion,
  }) async {
    try {
      Map<String, dynamic> body = {
        'email': email,
        'nombre_completo': nombreCompleto,
        'telefono': telefono,
        'direccion': direccion,
        'password': password,
      };

      final dio = DioConfig.dio;

      print(
          'AuthService: Enviando solicitud a ${dio.options.baseUrl}/Libreria/usuarios/crear-cliente/');
      print('AuthService: Cuerpo del registro: $body');

      final response =
          await dio.post('/Libreria/usuarios/crear-cliente/', data: body);

      print('AuthService: Código de estado: ${response.statusCode}');
      print('AuthService: Tipo de respuesta: ${response.data.runtimeType}');

      // Manejar diferentes tipos de respuesta
      if (response.data is Map<String, dynamic>) {
        final Map<String, dynamic> dataMap = response.data;
        print('AuthService: dataMap: $dataMap');

        if (response.statusCode == 201 || response.statusCode == 200) {
          return AuthResponse(
            token: dataMap['token'] ?? '',
            userId: dataMap['user_id'] ?? 0,
            email: email,
            nombreCompleto: nombreCompleto,
          );
        } else {
          throw Exception(dataMap['detail'] ?? 'Error al registrar usuario');
        }
      } else if (response.data is String) {
        print('AuthService: Respuesta como string: ${response.data}');
        throw Exception('Error al registrar usuario');
      }

      throw Exception('Error al registrar usuario');
    } catch (e) {
      print('AuthService: Error en register: $e');
      if (e is DioException) {
        throw _handleDioError(e);
      }
      throw Exception('Error inesperado: $e');
    }
  }

  /// Guarda los datos del usuario en las preferencias
  void saveUserPreferences(AuthResponse authResponse) {
    final prefs = UserPreferences();
    // Guardar token
    prefs.token = authResponse.token;
    print('AuthService: TOKEN GUARDADO: ${authResponse.token}');

    // Guardar el email
    if (authResponse.email != null) {
      prefs.email = authResponse.email!;
    }

    // Guardar el nombre si está disponible
    if (authResponse.nombreCompleto != null) {
      prefs.name = authResponse.nombreCompleto!;
    }

    // Guardar el ID del usuario
    prefs.clientId = authResponse.userId;
  }

  /// Cierra la sesión del usuario
  void logout() {
    final prefs = UserPreferences();
    prefs.token = '';
    prefs.email = '';
    prefs.name = '';
    prefs.clientId = 0;
  }

  /// Gestiona los errores de Dio
  Exception _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return Exception('Error de conexión: Tiempo de espera agotado.');
    } else if (e.type == DioExceptionType.connectionError) {
      return Exception('No se pudo conectar al servidor.');
    } else if (e.response?.statusCode == 401) {
      return Exception('Credenciales incorrectas.');
    } else if (e.response?.statusCode == 400) {
      // Intentar obtener el mensaje de error específico si existe
      if (e.response?.data is Map) {
        final errorMap = e.response!.data as Map;
        if (errorMap.containsKey('detail')) {
          return Exception(errorMap['detail']);
        }
      }
      return Exception('Datos de entrada inválidos.');
    } else {
      return Exception(DioConfig.handleDioError(e));
    }
  }
}
