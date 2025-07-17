import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeSwitch extends StatelessWidget {
  final VoidCallback? onThemeChanged;

  const ThemeSwitch({
    Key? key,
    this.onThemeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeMode = Theme.of(context).brightness;
    final isDarkMode = themeMode == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return RotationTransition(
            turns: animation,
            child: ScaleTransition(
              scale: animation,
              child: child,
            ),
          );
        },
        child: Icon(
          isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          key: ValueKey<bool>(isDarkMode),
          color: primaryColor,
        ),
      ),
      onPressed: onThemeChanged,
      tooltip: isDarkMode ? 'Cambiar a tema claro' : 'Cambiar a tema oscuro',
    );
  }
}
