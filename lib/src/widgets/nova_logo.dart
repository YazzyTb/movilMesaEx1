import 'package:flutter/material.dart';
import 'package:exam1_software_movil/src/constants/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class NovaLogo extends StatelessWidget {
  final double size;
  final bool isDark;

  const NovaLogo({
    Key? key,
    this.size = 40.0,
    this.isDark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryColor =
        isDark ? AppTheme.primaryDark : AppTheme.primaryLight;
    final Color textColor =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_stories_rounded,
              color: primaryColor,
              size: size,
            ),
            const SizedBox(width: 12),
            Text(
              'NOVA',
              style: GoogleFonts.montserrat(
                fontSize: size * 0.8,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        Text(
          'LIBRERÍA',
          style: GoogleFonts.montserrat(
            fontSize: size * 0.3,
            fontWeight: FontWeight.w600,
            color: textColor.withOpacity(0.8),
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }
}
