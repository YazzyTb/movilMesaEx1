import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

 // Brand colors (contraste naranja + azul + púrpura)
static const Color primaryLight = Color(0xFFFF6F00); // Naranja
static const Color secondaryLight = Color(0xFF039BE5); // Azul cielo
static const Color accentLight = Color(0xFF8E24AA); // Púrpura

static const Color primaryDark = Color(0xFFFF8F00); // Naranja más suave
static const Color secondaryDark = Color(0xFF40C4FF); // Azul claro
static const Color accentDark = Color(0xFFCE93D8); // Lavanda clara

// Backgrounds
static const Color backgroundLight = Color(0xFFFFFDE7); // Amarillo muy claro
static const Color backgroundDark = Color(0xFF121212);

// Surfaces
static const Color surfaceLight = Color(0xFFFFFFFF);
static const Color surfaceDark = Color(0xFF1E1E1E);

// Error colors
static const Color errorLight = Color(0xFFD84315); // Rojo cálido
static const Color errorDark = Color(0xFFFF8A65);  // Rojo suave

// Text
static const Color textPrimaryLight = Color(0xFF212121);
static const Color textSecondaryLight = Color(0xFF757575);
static const Color textPrimaryDark = Color(0xFFFFFFFF);
static const Color textSecondaryDark = Color(0xFFEEEEEE);

  // Light Theme
  static ThemeData light() {
    final ColorScheme colorScheme = const ColorScheme.light(
      primary: primaryLight,
      secondary: secondaryLight,
      tertiary: accentLight,
      background: backgroundLight,
      surface: surfaceLight,
      error: errorLight,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: textPrimaryLight,
      onSurface: textPrimaryLight,
      onError: Colors.white,
    );

    return _baseTheme(
      colorScheme: colorScheme,
      brightness: Brightness.light,
      textPrimary: textPrimaryLight,
      textSecondary: textSecondaryLight,
    );
  }

  // Dark Theme
  static ThemeData dark() {
    final ColorScheme colorScheme = const ColorScheme.dark(
      primary: primaryDark,
      secondary: secondaryDark,
      tertiary: accentDark,
      background: backgroundDark,
      surface: surfaceDark,
      error: errorDark,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onBackground: textPrimaryDark,
      onSurface: textPrimaryDark,
      onError: Colors.black,
    );

    return _baseTheme(
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      textPrimary: textPrimaryDark,
      textSecondary: textSecondaryDark,
    );
  }

  // Base Theme
  static ThemeData _baseTheme({
    required ColorScheme colorScheme,
    required Brightness brightness,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final TextTheme textTheme = GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textPrimary,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textPrimary,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: textSecondary,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.background,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: textPrimary,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: colorScheme.onBackground.withOpacity(0.1), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
        hintStyle: textTheme.bodyMedium
            ?.copyWith(color: textSecondary.withOpacity(0.7)),
        errorStyle: textTheme.bodySmall?.copyWith(color: colorScheme.error),
        suffixIconColor: colorScheme.onBackground.withOpacity(0.7),
        prefixIconColor: colorScheme.onBackground.withOpacity(0.7),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: colorScheme.onBackground.withOpacity(0.1),
        thickness: 1,
        space: 32,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.surface,
        contentTextStyle: textTheme.bodyMedium,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
