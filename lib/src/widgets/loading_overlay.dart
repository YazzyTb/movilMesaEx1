import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        // El contenido principal
        child,

        // El overlay de carga
        if (isLoading)
          Positioned.fill(
            child: Material(
              color: Colors.black54,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? colorScheme.surface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animación personalizada con el tema del proyecto
                      Container(
                        width: 80,
                        height: 80,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? colorScheme.primaryContainer
                              : colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
                          ),
                          strokeWidth: 4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        message ?? 'Procesando...',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Un StatefulWidget que maneja el estado global del loading para toda la app
class GlobalLoadingOverlay extends StatefulWidget {
  final Widget child;

  const GlobalLoadingOverlay({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  GlobalLoadingOverlayState createState() => GlobalLoadingOverlayState();

  /// Acceder al estado desde cualquier parte de la app
  static GlobalLoadingOverlayState of(BuildContext context) {
    return context.findAncestorStateOfType<GlobalLoadingOverlayState>()!;
  }
}

class GlobalLoadingOverlayState extends State<GlobalLoadingOverlay> {
  bool _isLoading = false;
  String? _message;

  /// Mostrar el loading overlay
  void show({String? message}) {
    setState(() {
      _isLoading = true;
      _message = message;
    });
  }

  /// Ocultar el loading overlay
  void hide() {
    setState(() {
      _isLoading = false;
      _message = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      message: _message,
      child: widget.child,
    );
  }
}
