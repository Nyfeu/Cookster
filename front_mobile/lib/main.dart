import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/onboarding/onboarding_screen.dart'; 
import 'screens/auth/auth_screen.dart'; 
import 'screens/user/profile_screen.dart';
import 'screens/user/edit_screen.dart';
import 'screens/recipe/recipe_screen.dart';
import 'theme/app_theme.dart';
import 'package:provider/provider.dart'; // [NOVO] Importe o provider
import 'providers/auth_provider.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
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
      // A rota inicial continua sendo a de onboarding
      initialRoute: OnboardingScreen.routeName,
      // Definimos as rotas nomeadas para a navegação
      routes: {
        OnboardingScreen.routeName: (context) => const OnboardingScreen(),
        // CORREÇÃO: Usando o nome correto da rota e da tela (AuthScreen)
        AuthScreen.routeName: (context) => const AuthScreen(),

        ProfileScreen.routeName: (context) {
          // Pega o ID passado como argumento
          final userId = ModalRoute.of(context)!.settings.arguments as String?;

          return ProfileScreen(userId: userId ?? 'ID_PADRAO_OU_ERRO');
        },

        EditProfileScreen.routeName: (context){

          final profileId = ModalRoute.of(context)!.settings.arguments as String?;

          return EditProfileScreen(userId: profileId ?? 'ID_PADRAO_OU_ERRO');
        },

        // [NOVO] Adicionando a rota da página de receita
        RecipePage.routeName: (context) {
          // Ela funciona exatamente como a ProfileScreen: precisa de um argumento
          final recipeId = ModalRoute.of(context)!.settings.arguments as String?;
          // Passamos o ID para o construtor da RecipeScreen (que adaptamos)
          // (Estou assumindo que o widget que adaptamos se chama 'RecipeScreen'
          // e que o nome do parâmetro é 'idReceita')
          return RecipePage(idReceita: recipeId ?? 'ID_RECEITA_PADRAO_OU_ERRO');
      },
    },
    );
  }
}

