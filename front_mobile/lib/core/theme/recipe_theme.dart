import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {

  // Mantém o mesmo esquema de cores da versão anterior em React.js

  static const Color primary = Color(0xFF38302E);
  static const Color secondary = Color(0xFFE89841);
  static const Color accent = Color(0xFF637F68);
  static const Color background = Color(0xFFFFF9EC);
  static const Color text = Color(0xFF4D6B5B);
  static const Color transition = Color(0xFFA8B8A5);  
  static const Color pageBackground = Color(0xE6E89841);

  // Tema geral da aplicação vide https://docs.flutter.dev/cookbook/design/themes (TUTORIAL)
  // disponível pelo documentação oficial do Flutter.

  static ThemeData get theme {
    return ThemeData(
      textTheme: GoogleFonts.poppinsTextTheme(),
      scaffoldBackgroundColor: pageBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: background,
      ),
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: background,
        secondary: secondary,
        onSecondary: primary,
        error: Colors.red,
        onError: Colors.white,
        background: background,
        onBackground: text,
        surface: pageBackground,
        onSurface: text,
        tertiary: accent,
        onTertiary: background,
      ),
      cardTheme: CardThemeData(
        color: background,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondary,
          textStyle: const TextStyle(
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}