import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


/// Global application color and text theme.
/// 
/// This was generated and adapted from ChatGPT because I personally suck at
/// composing nice looking color palletes. Some colors are a bit off for that
/// reason.
class AppTheme {
  static final text = TextTheme(
    headlineLarge: GoogleFonts.plusJakartaSans(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    ),

    headlineMedium: GoogleFonts.plusJakartaSans(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
    ),

    headlineSmall: GoogleFonts.plusJakartaSans(
      fontSize: 24,
      fontWeight: FontWeight.w600,
    ),

    titleLarge: GoogleFonts.plusJakartaSans(
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),

    titleMedium: GoogleFonts.plusJakartaSans(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),

    titleSmall: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),

    bodyLarge: GoogleFonts.plusJakartaSans(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),

    bodyMedium: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.45,
    ),

    bodySmall: GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),

    labelLarge: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),

    labelMedium: GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),

    labelSmall: GoogleFonts.plusJakartaSans(
      fontSize: 11,
      fontWeight: FontWeight.w500,
    ),
  );

  static final light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,

      primary: Color(0xFF6D28D9),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFE9DDFF),
      onPrimaryContainer: Color(0xFF25005A),

      secondary: Color(0xFF7C3AED),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFE9DDFF),
      onSecondaryContainer: Color(0xFF2B005F),

      tertiary: Color(0xFF9C2D78),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFFFD9EC),
      onTertiaryContainer: Color(0xFF3D0029),

      error: Color(0xFFBA1A1A),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),

      surface: Color(0xFFFCF8FF),
      onSurface: Color(0xFF1C1B20),
      surfaceContainerHigh: Color(0xFFE7E2E8),
      surfaceContainerHighest: Color(0xFFE7E0E8),
      onSurfaceVariant: Color(0xFF49454E),

      outline: Color(0xFF79747E),
      outlineVariant: Color(0xFFCAC4D0),

      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),

      inverseSurface: Color(0xFF313033),
      onInverseSurface: Color(0xFFF4EFF4),
      inversePrimary: Color(0xFFD0BCFF),
    ),

    appBarTheme: const AppBarTheme(
      centerTitle: true,
    ),

    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),

    textTheme: text,
  );

  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,

      primary: Color(0xFFD0BCFF),
      onPrimary: Color(0xFF381E72),
      primaryContainer: Color(0xFF4F378B),
      onPrimaryContainer: Color(0xFFE9DDFF),

      secondary: Color(0xFFD0BCFF),
      onSecondary: Color(0xFF381E72),
      secondaryContainer: Color(0xFF4F378B),
      onSecondaryContainer: Color(0xFFE9DDFF),

      tertiary: Color(0xFFFFA9D5),
      onTertiary: Color(0xFF5F0A43),
      tertiaryContainer: Color(0xFF7D245F),
      onTertiaryContainer: Color(0xFFFFD9EC),

      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),

      surface: Color(0xFF141218),
      onSurface: Color(0xFFE6E1E9),
      surfaceContainerHigh: Color(0xFF262528),
      surfaceContainerHighest: Color(0xFF323134),
      onSurfaceVariant: Color(0xFFCAC4D0),

      outline: Color(0xFF938F99),
      outlineVariant: Color(0xFF49454F),

      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),

      inverseSurface: Color(0xFFE6E1E9),
      onInverseSurface: Color(0xFF313033),
      inversePrimary: Color(0xFF6D28D9),
    ),

    appBarTheme: const AppBarTheme(
      centerTitle: true,
    ),

    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),

    textTheme: text,
  );
}


class TransactionColors {
  // Light theme
  static const incomeLight = Color.fromARGB(255, 193, 250, 213);
  static const expenseLight = Color.fromARGB(255, 255, 194, 194);

  // Dark theme
  static const incomeDark = Color(0xFF14532D);
  static const expenseDark = Color(0xFF7F1D1D);
}


/// Global application spacing scheme.
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;

  static const globalPadding = lg;
}
