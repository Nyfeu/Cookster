import 'package:flutter/material.dart';                      // Padrão do Flutter
import '../../../data/models/user_profile.dart';             // Modelo de Usuário
import '../../../data/services/profile_service.dart';        // Serviço de Perfil
import '../../widgets/profile_screen/info_panel.dart';       // Widget auxiliar InfoPanel
import '../../widgets/profile_screen/recipes_grid.dart';     // Widget auxiliar RecipesGrid
import 'package:provider/provider.dart';                     // Pacote Provider
import '../../providers/auth_provider.dart';                 // Provider de Autenticação

// Tela de Dados do Perfil
// Permite visualizar os dados do perfil do usuário
// Acessar a tela de edição e as receitas publicadas

class ProfileScreen extends StatefulWidget {

  // Rota da página de perfil
  static const String routeName = '/profile';
  
  // ID do usuário na página
  final String userId;

  // Controla se o Scaffold (estrutura básica da tela com AppBar) deve ser exibido
  // true: exibe o Scaffold completo com AppBar
  // false: exibe apenas o conteúdo do perfil, útil quando usado como widget filho em outras telas
  final bool showScaffold; 

  const ProfileScreen({
    super.key,
    required this.userId,
    this.showScaffold = true, 
  });

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {

  // O Perfil é recuperado assíncronamente, então é utilizado Future
  late Future<UserProfile> profileFuture;

  // Serviço de Perfil para comunicação com camada subjacente de dados
  final ProfileService profileService = ProfileService();

  // Estado inicial

  @override
  void initState() {
    super.initState();

    final token = Provider.of<AuthProvider>(context, listen: false).token;

    if (token != null) {
      // Passa o token para o serviço
      profileFuture = profileService.fetchUserProfile(widget.userId, token);
    } else {
      // Se não há token, o Future já retorna um erro.
      profileFuture = Future.error('Usuário não autenticado. Token nulo.');
    }
  }

  // Chamado por callbacks filhos quando o perfil foi atualizado
  void reloadProfile() {
    
    // Recupera o token de autenticação via AuthProvider
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    
    if (token != null) {
      setState(() {
        profileFuture = profileService.fetchUserProfile(widget.userId, token);
      });
    }

  }

  // Constrói a tela de perfil

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile>(
      future: profileFuture,
      builder: (context, snapshot) {

        // 'snapshot' serve para monitorar o estado do Future
        // e atualizar a UI conforme necessário

        // Mostra indicador de carregamento enquanto espera

        if (snapshot.connectionState == ConnectionState.waiting) {
          final loadingWidget = const Center(child: CircularProgressIndicator());

          if (widget.showScaffold) {
            return Scaffold(
              appBar: AppBar(title: const Text('Carregando...')),
              body: loadingWidget,
            );
          }
          return loadingWidget;
        }

        // Mostra mensagem de erro se ocorrer um problema

        if (snapshot.hasError) {
          final errorWidget = Center(
            child: Text(
              'Erro: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );

          if (widget.showScaffold) {
            return Scaffold(
              appBar: AppBar(title: const Text('Erro')),
              body: errorWidget,
            );
          }
          return errorWidget;
        }

        // Caso os dados estejam disponíveis

        if (snapshot.hasData) {
          final profile = snapshot.data!;
          final profileLayout = buildProfileLayout(context, profile);

          if (widget.showScaffold) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Perfil'),
              ),
              body: profileLayout,
            );
          }
          return profileLayout;
        }

        final defaultWidget =
            const Center(child: Text('Nenhum perfil encontrado.'));
        if (widget.showScaffold) {
          return Scaffold(
            appBar: AppBar(title: const Text('Perfil')),
            body: defaultWidget,
          );
        }
        return defaultWidget;
      },
    );
  }

  Widget buildProfileLayout(BuildContext context, UserProfile profile) {

    final bannerHeight = MediaQuery.of(context).size.height * 0.3;


    final infoPanelTopMargin = bannerHeight - 60;

    return SingleChildScrollView(
      child: Column(
        children: [

          Stack(

            // Conforme: https://api.flutter.dev/flutter/widgets/Stack-class.html

            clipBehavior: Clip.none,
            children: [

              Container(
                height: bannerHeight,
                width: double.infinity,
                decoration: const BoxDecoration(

                  // Conforme: https://api.flutter.dev/flutter/painting/BoxDecoration-class.html

                  image: DecorationImage(
                    image:
                        AssetImage('assets/images/bg.jpg'), 
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              Column(
                children: [
                  SizedBox(height: infoPanelTopMargin),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: InfoPanel(
                      profile: profile,
                      seguidores: 0,
                      seguindo: 0,
                      posts: 0,
                      onProfileUpdated: reloadProfile,
                    ),
                  ),
                ],
              ),
              
            ],
          ),

          Padding(
            padding: const EdgeInsets.only(
              top: 24.0,
              left: 16.0,
              right: 16.0,
              bottom: 32.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Receitas',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 10),
                RecipesGrid(),
              ],
            ),
          )
        ],
      ),
    );
  }
}