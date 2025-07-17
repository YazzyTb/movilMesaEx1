import 'package:exam1_software_movil/src/constants/constants.dart';
import 'package:exam1_software_movil/src/providers/providers.dart';
import 'package:exam1_software_movil/src/routes/routes.dart';
import 'package:exam1_software_movil/src/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomGradientBackground(
        isDark: isDark,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // App Bar with back button and toggle theme
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: colorScheme.primary,
                          ),
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, Routes.LOGIN);
                          },
                        ),
                        ThemeSwitch(
                          onThemeChanged: () => themeProvider.toggleTheme(),
                        ),
                      ],
                    ),
                  ),

                  // Logo
                  const SizedBox(height: 24),
                  NovaLogo(
                    size: 60,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 40),

                  // Register Title
                  Text(
                    'Crea tu cuenta',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Regístrate para acceder a todo nuestro catálogo',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Register form
                  ChangeNotifierProvider(
                    create: (BuildContext context) => RegisterFormProvider(),
                    child: const _RegisterForm(),
                  ),

                  const SizedBox(height: 24),

                  // Login button
                  _loginButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loginButton(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿Ya tienes una cuenta?',
          style: theme.textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, Routes.LOGIN);
          },
          child: Text('Iniciar sesión'),
        ),
      ],
    );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm();

  @override
  Widget build(BuildContext context) {
    final registerForm = Provider.of<RegisterFormProvider>(context);
    final theme = Theme.of(context);

    return Form(
      key: registerForm.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email field
          CustomTextField(
            label: 'Correo electrónico',
            hint: 'usuario@ejemplo.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onChanged: (value) => registerForm.email = value,
            validator: (value) {
              String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
              RegExp regExp = RegExp(pattern);
              return regExp.hasMatch(value ?? '')
                  ? null
                  : "Ingrese un email válido";
            },
          ),

          const SizedBox(height: 16),

          // Nombre completo field
          CustomTextField(
            label: 'Nombre completo',
            hint: 'Juan Pérez',
            prefixIcon: Icons.person_outline,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            onChanged: (value) => registerForm.nombreCompleto = value,
            validator: (value) => (value != null && value.length > 3)
                ? null
                : "Ingrese su nombre completo",
          ),

          const SizedBox(height: 16),

          // Teléfono field
          CustomTextField(
            label: 'Teléfono',
            hint: '77889900',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            onChanged: (value) => registerForm.telefono = value,
            validator: (value) => (value != null && value.length >= 7)
                ? null
                : "Ingrese un número de teléfono válido",
          ),

          const SizedBox(height: 16),

          // Dirección field
          CustomTextField(
            label: 'Dirección',
            hint: 'Av. Principal #123',
            prefixIcon: Icons.location_on_outlined,
            keyboardType: TextInputType.streetAddress,
            textInputAction: TextInputAction.next,
            onChanged: (value) => registerForm.direccion = value,
            validator: (value) => (value != null && value.length > 5)
                ? null
                : "Ingrese una dirección válida",
          ),

          const SizedBox(height: 16),

          // Password field
          CustomTextField(
            label: 'Contraseña',
            hint: '********',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            textInputAction: TextInputAction.next,
            onChanged: (value) => registerForm.password = value,
            validator: (value) => (value != null && value.length >= 8)
                ? null
                : 'Mínimo 8 caracteres',
          ),

          const SizedBox(height: 16),

          // Confirm Password field
          CustomTextField(
            label: 'Confirmar contraseña',
            hint: '********',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onChanged: (value) => registerForm.passwordConfirmation = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirme su contraseña';
              }
              if (value != registerForm.password) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Register Button
          CustomButton(
            text: 'Registrarme',
            isLoading: registerForm.isLoading,
            onPressed: () async {
              FocusScope.of(context).unfocus();
              if (!registerForm.isValidForm()) return;

              registerForm.isLoading = true;
              final bool registered = await registerForm.register();
              registerForm.isLoading = false;

              if (registered) {
                if (!context.mounted) return;
                Navigator.pushReplacementNamed(context, Routes.HOME);
                return;
              }

              if (!context.mounted) return;
              _showErrorDialog(context, registerForm.errorMessage);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showErrorDialog(BuildContext context, String error) {
    final theme = Theme.of(context);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error_outline, color: theme.colorScheme.error),
              const SizedBox(width: 8),
              Text(
                'Error de registro',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ),
          content: Text(
            error,
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}
