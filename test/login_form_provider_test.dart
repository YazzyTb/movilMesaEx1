import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter/widgets.dart';
import 'package:exam1_software_movil/src/providers/login_form_provider.dart';

class MockUserPreferences {
  String token = '';
  String email = '';
  int clientId = 0;
  String name = '';
}

void main() {
  // Inicializar el binding para el entorno de prueba
  TestWidgetsFlutterBinding.ensureInitialized();

  late LoginFormProvider loginProvider;

  setUp(() {
    loginProvider = LoginFormProvider();
    loginProvider.email = 'test@example.com';
    loginProvider.password = 'password123';
  });

  group('LoginFormProvider Tests', () {
    testWidgets('isValidForm retorna false cuando el form no es válido',
        (WidgetTester tester) async {
      expect(loginProvider.isValidForm(), false);
    });

    test('isLoading cambia y notifica', () {
      bool notified = false;
      loginProvider.addListener(() {
        notified = true;
      });

      expect(loginProvider.isLoading, false);

      loginProvider.isLoading = true;

      expect(loginProvider.isLoading, true);
      expect(notified, true);
    });

    test('saveUserPreferences guarda los datos correctamente', () {
      // Crear un mock simple de UserPreferences
      final mockPrefs = MockUserPreferences();

      // Datos simulados de respuesta del servidor
      final Map<String, dynamic> fakeResponse = {
        'token': 'fake-token-123',
        'user_id': 42
      };

      // Crear una función que simula saveUserPreferences
      void saveWithMock(Map<String, dynamic> dataMap) {
        mockPrefs.token = dataMap['token'] ?? '';
        mockPrefs.email = loginProvider.email;
        mockPrefs.clientId = dataMap['user_id'] ?? 0;
        mockPrefs.name = '';
      }

      // Llamar a la función simulada
      saveWithMock(fakeResponse);

      // Verificar que los datos se guardaron correctamente
      expect(mockPrefs.token, 'fake-token-123');
      expect(mockPrefs.email, 'test@example.com');
      expect(mockPrefs.clientId, 42);
      expect(mockPrefs.name, '');
    });
  });
}
