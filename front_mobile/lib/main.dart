import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/auth/auth_screen.dart';
import 'presentation/screens/user/profile_screen.dart';
import 'presentation/screens/user/edit_screen.dart';
import 'presentation/screens/recipe/recipe_screen.dart';
import 'presentation/screens/pantry/pantry_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/pantry_provider.dart';
import 'data/services/recipe_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => PantryProvider()),
        Provider(create: (_) => RecipeService()), 
      ],
      child: const MyApp(),
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
      routes: {
        OnboardingScreen.routeName: (context) => const OnboardingScreen(),
        AuthScreen.routeName: (context) => const AuthScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),

        PantryScreen.routeName: (context) => const PantryScreen(),

        ProfileScreen.routeName: (context) {
          final userId = ModalRoute.of(context)!.settings.arguments as String?;
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