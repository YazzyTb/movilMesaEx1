import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:provider/provider.dart';

import 'package:exam1_software_movil/src/providers/shopping_cart_provider.dart';
import 'package:exam1_software_movil/src/share_preferens/user_preferences.dart';
import 'package:exam1_software_movil/src/constants/theme.dart';
import 'package:exam1_software_movil/src/config/env_config.dart';

class PayPage extends StatefulWidget {
  const PayPage({super.key});

  @override
  State<PayPage> createState() => _PayPageState();
}

class _PayPageState extends State<PayPage> {
  CardFormEditController controller = CardFormEditController();
  final prefs = UserPreferences();
  bool _isProcessing = false;
  String? _stripeKey;
  // Guardar una referencia segura al ScaffoldMessengerState
  late ScaffoldMessengerState _scaffoldMessenger;

  @override
  void initState() {
    controller.addListener(update);
    _stripeKey = EnvConfig.stripePublishableKey;
    // Asegurar que Stripe esté inicializado
    _initStripe();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Guardar una referencia al ScaffoldMessenger que sea segura de usar incluso después de la disposición
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  Future<void> _initStripe() async {
    try {
      // Corregir la clave si tiene saltos de línea
      String stripeKey = EnvConfig.stripePublishableKey;
      // Eliminar cualquier espacio en blanco, nueva línea o retorno de carro
      stripeKey = stripeKey.replaceAll(RegExp(r'\s+'), '');

      // Reinicializar Stripe durante la carga de la página
      Stripe.publishableKey = stripeKey;
      await Stripe.instance.applySettings();
      print('Stripe inicializado correctamente');
    } catch (e) {
      print('Error al inicializar Stripe: $e');
    }
  }

  void update() => setState(() {});

  @override
  void dispose() {
    controller.removeListener(update);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shoppingCartProvider = Provider.of<ShoppingCartProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalizar compra'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Resumen de compra
              Card(
                elevation: 4,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resumen de compra',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Productos: ${shoppingCartProvider.items.length}',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total a pagar:',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                          Text(
                            '${shoppingCartProvider.totalAmount.toStringAsFixed(2)}',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Stripe Logo
              Center(
                child: Image.asset(
                  "assets/stripe-logo.png",
                  height: 50,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                "Introduce los datos de tu tarjeta",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Card Form
              CardFormField(
                style: CardFormStyle(
                  textColor: isDark ? Colors.white : Colors.black87,
                  placeholderColor: isDark ? Colors.white70 : Colors.grey,
                  backgroundColor:
                      isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  borderColor: colorScheme.primary,
                  borderRadius: 12,
                  fontSize: 16,
                ),
                controller: controller,
              ),

              const SizedBox(height: 24),

              // Payment Button
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: colorScheme.onPrimary,
                    backgroundColor: colorScheme.primary,
                    disabledBackgroundColor: Colors.grey.shade400,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: !controller.details.complete ||
                          shoppingCartProvider.isLoading ||
                          _isProcessing
                      ? null
                      : () async {
                          setState(() {
                            _isProcessing = true;
                          });

                          try {
                            print('PayPage: Iniciando proceso de pago');

                            // Usar la referencia segura al ScaffoldMessenger
                            _scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        )),
                                    SizedBox(width: 12),
                                    Text('Procesando pago con Stripe...'),
                                  ],
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );

                            // Procesamiento de pago con Stripe usando el provider
                            final success =
                                await shoppingCartProvider.processPurchase();

                            // Verificar si el widget aún está montado antes de continuar
                            if (!mounted) {
                              print(
                                  'PayPage: Widget no está montado, deteniendo la operación');
                              return;
                            }

                            if (!success) {
                              print(
                                  'PayPage: Error en el procesamiento del pago');

                              await _showDialogError(
                                  context,
                                  "Error",
                                  Colors.red,
                                  shoppingCartProvider.errorMessage ??
                                      "Ocurrió un error al procesar el pago");
                            } else {
                              print('PayPage: Pago procesado correctamente');
                              // Si todo salió bien
                              shoppingCartProvider
                                  .clearCart(); // Limpiamos el carrito

                              // Mostrar diálogo de éxito y luego navegar
                              await _showDialogError(
                                  context,
                                  "¡Compra exitosa!",
                                  Colors.green,
                                  "¡Tu pedido ha sido creado correctamente! Pronto recibirás más información.");

                              controller.clear();

                              // Verificar de nuevo si el widget está montado antes de navegar
                              if (mounted) {
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                              }
                            }
                          } catch (e) {
                            print(
                                'PayPage: Excepción durante el proceso de pago: $e');

                            // Verificar si el widget aún está montado
                            if (mounted) {
                              await _showDialogError(
                                  context,
                                  "Error",
                                  Colors.red,
                                  "Ocurrió un error inesperado: ${e.toString()}");
                            }
                          } finally {
                            // Solo actualizar el estado si el widget sigue montado
                            if (mounted) {
                              setState(() {
                                _isProcessing = false;
                              });
                            }
                          }
                        },
                  icon: _isProcessing
                      ? Container(
                          width: 24,
                          height: 24,
                          padding: const EdgeInsets.all(2.0),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Icon(Icons.payment),
                  label: Text(
                    _isProcessing ? "Procesando..." : "Pagar ahora",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Seguridad
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: isDark ? Colors.white70 : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Pago seguro con Stripe",
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showDialogError(BuildContext context, String title,
    Color colorMessage, String errorMessage) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Text(title,
              style: TextStyle(
                color: colorMessage,
                fontWeight: FontWeight.bold,
              )),
          content: Row(
            children: [
              Icon(
                title.contains("exitosa") ? Icons.check_circle : Icons.error,
                color: colorMessage,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  errorMessage,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Aceptar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      });
}
