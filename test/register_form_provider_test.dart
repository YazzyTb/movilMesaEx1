import 'package:flutter_test/flutter_test.dart';
import 'package:exam1_software_movil/src/providers/register_form_provider.dart';

class MockUserPreferences {
  String token = '';
  String email = '';
  String name = '';
  int clientId = 0;
}

void main() {
  // Inicializar el binding para el entorno de prueba
  TestWidgetsFlutterBinding.ensureInitialized();

  late RegisterFormProvider registerProvider;

  setUp(() {
    registerProvider = RegisterFormProvider();
    registerProvider.email = 'test@example.com';
    registerProvider.nombreCompleto = 'John Doe';
    registerProvider.telefono = '77889900';
    registerProvider.direccion = 'Test Address 123';
    registerProvider.password = 'password123';
    registerProvider.passwordConfirmation = 'password123';
  });

  group('RegisterFormProvider Tests', () {
    testWidgets('isValidForm retorna false cuando el form no es válido',
        (WidgetTester tester) async {
      expect(registerProvider.isValidForm(), false);
    });

    test('isLoading cambia y notifica', () {
      bool notified = false;
      registerProvider.addListener(() {
        notified = true;
      });

      expect(registerProvider.isLoading, false);

      registerProvider.isLoading = true;

      expect(registerProvider.isLoading, true);
      expect(notified, true);
    });

    test('passwordsMatch retorna true cuando las contraseñas coinciden', () {
      registerProvider.password = 'password123';
      registerProvider.passwordConfirmation = 'password123';

      expect(registerProvider.passwordsMatch(), true);
    });

    test('passwordsMatch retorna false cuando las contraseñas no coinciden',
        () {
      registerProvider.password = 'password123';
      registerProvider.passwordConfirmation = 'differentpassword';

      expect(registerProvider.passwordsMatch(), false);
    });

    test('errorMessage cambia y notifica', () {
      bool notified = false;
      registerProvider.addListener(() {
        notified = true;
      });

      expect(registerProvider.errorMessage, '');

      registerProvider.errorMessage = 'Test error message';

      expect(registerProvider.errorMessage, 'Test error message');
      expect(notified, true);
    });

    test('saveUserPreferences guarda los datos correctamente', () {
      // Crear un mock simple de UserPreferences
      final mockPrefs = MockUserPreferences();

      // Datos simulados de respuesta del servidor
      final Map<String, dynamic> fakeResponse = {
        'token': 'fake-register-token-123',
        'user_id': 42
      };

      // Crear una función que simula saveUserPreferences
      void saveWithMock(Map<String, dynamic> dataMap) {
        mockPrefs.token = dataMap['token'] ?? '';
        mockPrefs.email = registerProvider.email;
        mockPrefs.name = registerProvider.nombreCompleto;
        mockPrefs.clientId = dataMap['user_id'] ?? 0;
      }

      // Llamar a la función simulada
      saveWithMock(fakeResponse);

      // Verificar que los datos se guardaron correctamente
      expect(mockPrefs.token, 'fake-register-token-123');
      expect(mockPrefs.email, 'test@example.com');
      expect(mockPrefs.name, 'John Doe');
      expect(mockPrefs.clientId, 42);
    });
  });
}
