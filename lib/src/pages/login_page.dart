import 'package:exam1_software_movil/src/constants/constants.dart';
import 'package:exam1_software_movil/src/providers/providers.dart';
import 'package:exam1_software_movil/src/routes/routes.dart';
import 'package:exam1_software_movil/src/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
                  // App Bar with toggle theme
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ThemeSwitch(
                          onThemeChanged: () => themeProvider.toggleTheme(),
                        ),
                      ],
                    ),
                  ),

                  // Logo
                  const SizedBox(height: 40),
                  NovaLogo(
                    size: 70,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 50),

                  // Welcome Text
                  Text(
                    '¡Bienvenido de vuelta!',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Inicia sesión para continuar',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Login form
                  ChangeNotifierProvider(
                    create: (BuildContext context) => LoginFormProvider(),
                    child: const _LoginForm(),
                  ),

                  const SizedBox(height: 24),

                  
                  

                  const SizedBox(height: 24),

                  // Create new account
                  _newAccountButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _newAccountButton(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿No tienes una cuenta?',
          style: theme.textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, Routes.REGISTER);
          },
          child: Text('Regístrate'),
        ),
      ],
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm();

  @override
  Widget build(BuildContext context) {
    final loginForm = Provider.of<LoginFormProvider>(context);
    final theme = Theme.of(context);

    return Form(
      key: loginForm.formKey,
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
            onChanged: (value) => loginForm.email = value,
            validator: (value) {
              return value != null && value.length > 3
                  ? null
                  : "Ingrese un email válido";
            },
          ),

          const SizedBox(height: 20),

          // Password field
          CustomTextField(
            label: 'Contraseña',
            hint: '********',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onChanged: (value) => loginForm.password = value,
            validator: (value) => (value != null && value.length > 7)
                ? null
                : 'Mínimo 8 caracteres',
          ),

          // Forgot Password link
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Implement forgot password
              },
              child: Text('¿Olvidaste tu contraseña?'),
            ),
          ),

          const SizedBox(height: 24),

          // Sign In Button
          CustomButton(
            text: 'Iniciar sesión',
            isLoading: loginForm.isLoading,
            onPressed: () async {
              FocusScope.of(context).unfocus();
              if (!loginForm.isValidForm()) return;

              loginForm.isLoading = true;
              bool auth = await loginForm.authenticate();
              loginForm.isLoading = false;

              if (auth) {
                Navigator.pushReplacementNamed(context, Routes.HOME);
                return;
              }

              if (!context.mounted) return;
              _showErrorDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showErrorDialog(BuildContext context) {
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
                'Error de inicio de sesión',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ),
          content: Text(
            'El correo electrónico o la contraseña son incorrectos. Inténtalo de nuevo.',
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
