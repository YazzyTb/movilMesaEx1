import 'package:flutter/material.dart';
import 'package:exam1_software_movil/src/services/auth_service.dart';

/// Provider para gestionar el formulario de registro y su estado
class RegisterFormProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String email = '';
  String nombreCompleto = '';
  String telefono = '';
  String direccion = '';
  String password = '';
  String passwordConfirmation = '';

  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set errorMessage(String value) {
    _errorMessage = value;
    notifyListeners();
  }

  /// Valida el formulario
  bool isValidForm() => formKey.currentState?.validate() ?? false;

  /// Verifica que las contraseñas coinciden
  bool passwordsMatch() => password == passwordConfirmation;

  /// Registra un nuevo usuario con los datos proporcionados
  Future<bool> register() async {
    try {
      isLoading = true;

      final authResponse = await _authService.register(
        email: email,
        password: password,
        nombreCompleto: nombreCompleto,
        telefono: telefono,
        direccion: direccion,
      );

      if (authResponse != null) {
        _authService.saveUserPreferences(authResponse);
        print(
            'RegisterFormProvider: Registro exitoso, userId: ${authResponse.userId}');
        return true;
      }

      errorMessage = 'Error al registrar usuario';
      return false;
    } catch (e) {
      print('RegisterFormProvider: Error en register: $e');
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
    }
  }
}
