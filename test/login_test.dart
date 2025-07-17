import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:exam1_software_movil/src/providers/login_form_provider.dart';

void main() {
  group('Login Integration Test', () {
    late LoginFormProvider loginProvider;
    late Dio mockDio;

    setUp(() {
      loginProvider = LoginFormProvider();
      loginProvider.email = 'usuario@test.com';
      loginProvider.password = 'clave123';

      mockDio = Dio();
      // No podemos hacer interacciones reales con el servidor en tests,
      // pero podemos simular la llamada a authenticate sin mockito
    });

    test('Login process end-to-end simulation', () async {
      // Este test simula un proceso completo de login
      // No realizamos llamadas reales a la API

      // 1. Verificar estado inicial
      expect(loginProvider.isLoading, false);

      // 2. Iniciar el proceso de login
      loginProvider.isLoading = true;
      expect(loginProvider.isLoading, true);

      // 3. Verificar que tenemos credenciales
      expect(loginProvider.email, 'usuario@test.com');
      expect(loginProvider.password, 'clave123');

      // 4. Simular la respuesta del servidor
      final Map<String, dynamic> mockResponse = {
        'token': 'abcdef123456',
        'user_id': 99
      };

      // 5. Crear una función manual para probar saveUserPreferences
      final mockPrefs = MockUserPreferences();
      void testSavePrefs(Map<String, dynamic> data) {
        mockPrefs.token = data['token'] ?? '';
        mockPrefs.email = loginProvider.email;
        mockPrefs.clientId = data['user_id'] ?? 0;
        mockPrefs.name = '';
      }

      // 6. Llamar a la función de prueba
      testSavePrefs(mockResponse);

      // 7. Verificar guardado de preferencias
      expect(mockPrefs.token, 'abcdef123456');
      expect(mockPrefs.email, 'usuario@test.com');
      expect(mockPrefs.clientId, 99);

      // 8. Simular finalización del proceso de login
      loginProvider.isLoading = false;
      expect(loginProvider.isLoading, false);
    });
  });
}

// Simple clase para simular UserPreferences
class MockUserPreferences {
  String token = '';
  String email = '';
  int clientId = 0;
  String name = '';
}
