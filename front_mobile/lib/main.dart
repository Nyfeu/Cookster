import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Importe o pacote de fontes
import 'screens/onboarding/onboarding_screen.dart';
import 'theme/app_theme.dart'; // Importe o nosso tema

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cookster',
      theme: ThemeData(
        // Define as cores principais e de fundo baseadas no nosso tema
        colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.secondaryColor),
        scaffoldBackgroundColor: AppTheme.backgroundColor,
        // Define a fonte 'Poppins' como padrão para todo o app
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        useMaterial3: true,
      ),
      home: const OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

