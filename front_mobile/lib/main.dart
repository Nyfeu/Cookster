import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/onboarding/onboarding_screen.dart'; 
import 'screens/auth/auth_screen.dart'; 
import 'screens/user/profile_screen.dart';
import 'screens/user/edit_screen.dart';
import 'screens/recipe/recipe_screen.dart';
import 'theme/app_theme.dart';

// --- [ALTERAÇÕES] ---
// 1. REMOVA as importações do Provider
// import 'package:provider/provider.dart';
// import 'providers/auth_provider.dart';

// 2. ADICIONE a importação do seu BLoC global
import 'providers/auth_bloc.dart'; 
// --- [FIM DAS ALTERAÇÕES] ---


// 3. Transforme o 'main' em 'async'
void main() async {
  
  // 4. Garanta que o Flutter esteja inicializado antes de chamadas 'await'
  WidgetsFlutterBinding.ensureInitialized();

  // 5. Chame o 'tryAutoLogin' ANTES de rodar o app
  // Isso popula o BLoC com dados do SharedPreferences.
  await authBloc.tryAutoLogin();

  // 6. Remova o 'ChangeNotifierProvider'
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // O MaterialApp e todas as suas rotas permanecem EXATAMENTE IGUAIS.
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

        ProfileScreen.routeName: (context) {
          final userId = ModalRoute.of(context)!.settings.arguments as String?;
          return ProfileScreen(userId: userId ?? 'ID_PADRAO_OU_ERRO');
        },

        EditProfileScreen.routeName: (context){
          final profileId = ModalRoute.of(context)!.settings.arguments as String?;
          return EditProfileScreen(userId: profileId ?? 'ID_PADRAO_OU_ERRO');
        },

        RecipePage.routeName: (context) {
          final recipeId = ModalRoute.of(context)!.settings.arguments as String?;
          return RecipePage(idReceita: recipeId ?? 'ID_RECEITA_PADRAO_OU_ERRO');
        },
      },
    );
  }
}