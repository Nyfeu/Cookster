import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/user/profile_screen.dart';
import 'screens/user/edit_screen.dart';
import 'screens/recipe/recipe_screen.dart';
import 'screens/pantry/pantry_screen.dart';
import 'screens/home_screen.dart'; // Import da HomeScreen
import 'theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/pantry_provider.dart';
import 'services/recipe_service.dart';

void main() {
  runApp(
    // 1. Use MultiProvider para fornecer TODOS os seus providers
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => PantryProvider()),
        Provider(create: (_) => RecipeService()), 
      ],
      child: const MyApp(), // <-- 3. O child é o MyApp
    ),
  );
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
      // Definimos as rotas nomeadas para a navegação
      routes: {
        OnboardingScreen.routeName: (context) => const OnboardingScreen(),
        AuthScreen.routeName: (context) => const AuthScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(), // [CORRETO] Rota adicionada

        PantryScreen.routeName: (context) => const PantryScreen(),

        ProfileScreen.routeName: (context) {
          final userId = ModalRoute.of(context)!.settings.arguments as String?;
          // [CORRETO] Rota de perfil (para ver outros usuários)
          // continua usando o Scaffold padrão
          return ProfileScreen(userId: userId ?? 'ID_PADRAO_OU_ERRO');
        },

        EditProfileScreen.routeName: (context) {
          final profileId =
              ModalRoute.of(context)!.settings.arguments as String?;
          return EditProfileScreen(userId: profileId ?? 'ID_PADRAO_OU_ERRO');
        },

        RecipePage.routeName: (context) {
          final recipeId =
              ModalRoute.of(context)!.settings.arguments as String?;
          return RecipePage(idReceita: recipeId ?? 'ID_RECEITA_PADRAO_OU_ERRO');
        },
      },
    );
  }
}