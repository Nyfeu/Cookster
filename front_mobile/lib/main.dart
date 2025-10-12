import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/onboarding/onboarding_screen.dart'; // Sua tela inicial (onboarding)
import 'screens/auth/auth_screen.dart'; // A nova tela de login
import 'theme/app_theme.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.secondaryColor),
        scaffoldBackgroundColor: AppTheme.backgroundColor,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: OnboardingScreen.routeName,
      routes: {
        OnboardingScreen.routeName: (context) => const OnboardingScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        // Se você tiver uma tela principal após o login
        // '/home': (context) => const HomeScreen(),
      },
    );
  }
}