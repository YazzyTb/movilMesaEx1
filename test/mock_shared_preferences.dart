import 'package:shared_preferences/shared_preferences.dart';

/// Configura mocks para SharedPreferences para usarse en tests
Future<void> setUpSharedPreferencesForTests() async {
  // Configura valores falsos para las preferencias
  SharedPreferences.setMockInitialValues({
    'token': '',
    'email': '',
    'name': '',
    'image': '',
    'clientId': 0,
    'selectedPage': 0,
  });
}
