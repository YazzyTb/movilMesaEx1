import 'package:flutter/material.dart';
import 'package:exam1_software_movil/src/services/auth_service.dart';

/// Provider para gestionar el formulario de login y su estado
class LoginFormProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Valida el formulario
  bool isValidForm() => formKey.currentState?.validate() ?? false;

  /// Autentica al usuario con las credenciales proporcionadas
  Future<bool> authenticate() async {
    try {
      isLoading = true;

      final authResponse = await _authService.login(email, password);

      if (authResponse != null) {
        _authService.saveUserPreferences(authResponse);

        // Verificar que el token se guardó correctamente
        print(
            'LoginFormProvider: Autenticación exitosa, userId: ${authResponse.userId}');

        return true;
      }

      _errorMessage = 'Credenciales incorrectas';
      return false;
    } catch (e) {
      print('LoginFormProvider: Error en authenticate: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
    }
  }
}
