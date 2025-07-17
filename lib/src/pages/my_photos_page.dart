import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:exam1_software_movil/src/share_preferens/user_preferences.dart';
import 'package:exam1_software_movil/src/widgets/custom_gradient_background.dart';
import 'package:exam1_software_movil/src/widgets/nova_logo.dart';
import 'package:exam1_software_movil/src/routes/routes.dart';
import 'package:exam1_software_movil/src/providers/providers.dart';
import 'package:exam1_software_movil/src/providers/shopping_cart_provider.dart';

class MyPhotosPage extends StatelessWidget {
  const MyPhotosPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prefs = UserPreferences();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final cartProvider = Provider.of<ShoppingCartProvider>(context);

    return CustomGradientBackground(
      isDark: isDark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header with logo and title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      NovaLogo(
                        size: 32,
                        isDark: isDark,
                      ),
                      const Spacer(),
                      Text(
                        "Mi Perfil",
                        style: theme.textTheme.headlineSmall,
                      ),
                      const Spacer(),
                      const SizedBox(width: 32), // Balance the logo
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Profile picture
                  Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.primary.withOpacity(0.1),
                          border: Border.all(
                            color: colorScheme.primary,
                            width: 3,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: prefs.image.isNotEmpty
                              ? Image.network(
                                  prefs.image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      size: 60,
                                      color: colorScheme.primary,
                                    );
                                  },
                                )
                              : Icon(
                                  Icons.person,
                                  size: 60,
                                  color: colorScheme.primary,
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.edit,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // User name
                  Text(
                    prefs.name.isNotEmpty ? prefs.name : "Usuario",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // User email
                  Text(
                    prefs.email.isNotEmpty ? prefs.email : "usuario@email.com",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Theme toggle
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Theme toggle
                          ListTile(
                            leading: Icon(
                              isDark ? Icons.dark_mode : Icons.light_mode,
                              color: colorScheme.primary,
                            ),
                            title: Text(
                              isDark ? "Modo oscuro" : "Modo claro",
                              style: theme.textTheme.titleMedium,
                            ),
                            trailing: Switch(
                              value: isDark,
                              activeColor: colorScheme.primary,
                              onChanged: (value) {
                                themeProvider.toggleTheme();
                              },
                            ),
                          ),

                          const Divider(),

                          // Account settings
                          ListTile(
                            leading: Icon(
                              Icons.settings,
                              color: colorScheme.primary,
                            ),
                            title: Text(
                              "Configuración de cuenta",
                              style: theme.textTheme.titleMedium,
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                            onTap: () {
                              // Navigate to account settings
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      const Text('Función no implementada'),
                                  backgroundColor: colorScheme.primary,
                                ),
                              );
                            },
                          ),

                          const Divider(),

                          // Shopping history
                          ListTile(
                            leading: Icon(
                              Icons.history,
                              color: colorScheme.primary,
                            ),
                            title: Text(
                              "Historial de compras",
                              style: theme.textTheme.titleMedium,
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                  context, Routes.ORDER_HISTORY);
                            },
                          ),

                          const Divider(),

                          // Notifications
                          ListTile(
                            leading: Icon(
                              Icons.notifications,
                              color: colorScheme.primary,
                            ),
                            title: Text(
                              "Notificaciones",
                              style: theme.textTheme.titleMedium,
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                            onTap: () {
                              // Navigate to notifications
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      const Text('Función no implementada'),
                                  backgroundColor: colorScheme.primary,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // App info
                  Text(
                    "NOVA Librería v1.0.0",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.5),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Show confirmation dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              "Cerrar sesión",
                              style: theme.textTheme.titleLarge,
                            ),
                            content: Text(
                              "¿Estás seguro que deseas cerrar sesión?",
                              style: theme.textTheme.bodyMedium,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Cancelar"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  cartProvider.clearCart();
                                  prefs.clearUser();
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, Routes.LOGIN, (route) => false);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.error,
                                  foregroundColor: colorScheme.onError,
                                ),
                                child: Text("Cerrar sesión"),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text("Cerrar sesión"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
