import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/onboarding/onboarding_screen.dart'; 
import 'screens/auth/auth_screen.dart'; 
import 'screens/user/profile_screen.dart';
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
      // A rota inicial continua sendo a de onboarding
      initialRoute: OnboardingScreen.routeName,
      // Definimos as rotas nomeadas para a navegação
      routes: {
        OnboardingScreen.routeName: (context) => const OnboardingScreen(),
        // CORREÇÃO: Usando o nome correto da rota e da tela (AuthScreen)
        AuthScreen.routeName: (context) => const AuthScreen(),

        ProfileScreen.routeName: (context) => ProfileScreen(userId: '1749171330622')
      },
    );
  }
}

