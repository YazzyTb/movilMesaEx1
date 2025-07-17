import 'package:flutter/material.dart';
import 'package:exam1_software_movil/src/constants/theme.dart';

class CustomGradientBackground extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const CustomGradientBackground({
    Key? key,
    required this.child,
    this.isDark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  AppTheme.backgroundDark,
                  AppTheme.primaryDark.withOpacity(0.3),
                  AppTheme.backgroundDark,
                ]
              : [
                  AppTheme.backgroundLight,
                  AppTheme.primaryLight.withOpacity(0.1),
                  AppTheme.backgroundLight,
                ],
        ),
      ),
      child: child,
    );
  }
}
