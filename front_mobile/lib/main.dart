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

    // Utilizamos o pacote provider (https://pub.dev/packages/provider) [Flutter Favorite] para 
    // gerenciar o estado da aplicação de forma simples e prática - ao invés de BLoC, MobX etc.

    // O MultiProvider no topo da árvore de widgets permite injetar múltiplos providers
    // que estarão disponíveis para toda a aplicação. 

    MultiProvider(

      providers: [

        // ChangeNotifierProvider cria e gerencia o ciclo de vida dos providers que estendem ChangeNotifier
        // (como AuthProvider e PantryProvider), permitindo notificar os listeners sobre mudanças de estado.

        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => PantryProvider()),

        // Provider simples para RecipeService, que não precisa notificar mudanças de estado, 
        // apenas fornece métodos para buscar dados da API.  
        
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

      // Configurações gerais da aplicação

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
      
      // Rota inicial da aplicação é a tela de onboarding (usando o pacote 'introduction_screen')
      
      initialRoute: OnboardingScreen.routeName,

      routes: {

        // Definição das rotas nomeadas da aplicação
        // Cada rota mapeia um nome para um widget de tela específico
        // Isso facilita a navegação entre telas usando nomes em vez de instanciar widgets diretamente

        OnboardingScreen.routeName: (context) => const OnboardingScreen(),
        AuthScreen.routeName: (context) => const AuthScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
        PantryScreen.routeName: (context) => const PantryScreen(),

        // Rotas com argumentos extraem os parâmetros usando ModalRoute
        // Exemplo: ProfileScreen e EditProfileScreen recebem IDs de usuário como argumentos
        // Isso é necessário para instanciação correta dos widgets com os dados necessários

        ProfileScreen.routeName: (context) {
          final userId = ModalRoute.of(context)!.settings.arguments as String?;
          return ProfileScreen(userId: userId ?? 'ID_PADRAO_OU_ERRO');
        },
        EditProfileScreen.routeName: (context) {
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