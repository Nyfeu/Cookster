// lib/theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Mapeamento das suas variáveis CSS :root
class AppTheme {
  static const Color primary = Color(0xFF38302E);
  static const Color secondary = Color(0xFFE89841);
  static const Color accent = Color(0xFF637F68);
  static const Color background = Color(0xFFFFF9EC);
  static const Color text = Color(0xFF4D6B5B);
  static const Color transition = Color(0xFFA8B8A5);
  
  // Cor de fundo da página (do seu .page)
  static const Color pageBackground = Color(0xE6E89841); // rgba(232, 152, 65, 0.9)

  static ThemeData get theme {
    return ThemeData(
      // Fonte padrão (Poppins)
      textTheme: GoogleFonts.poppinsTextTheme(),

      // Cor de fundo principal do app
      scaffoldBackgroundColor: pageBackground,

      // Tema da AppBar (seu .nav)
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: background, // Cor do texto e ícones na appbar
      ),

      // Definição das cores principais
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: background,
        secondary: secondary,
        onSecondary: primary,
        error: Colors.red,
        onError: Colors.white,
        background: background,       // Cor de fundo dos Cards
        onBackground: text,           // Cor do texto principal
        surface: pageBackground,      // Cor de fundo da página
        onSurface: text,
        
        // Mapeamentos extras
        tertiary: accent,
        onTertiary: background,
      ),

      // Tema dos cards (para os box-shadow)
      cardTheme: CardThemeData(
        color: background,
        elevation: 4, // Sombra
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        shadowColor: Colors.black.withOpacity(0.3),
      ),

      // Tema dos TextButtons (seus .user-link)
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