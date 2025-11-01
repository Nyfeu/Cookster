import 'package:flutter/material.dart';
import '../../models/user_profile.dart'; // Ajuste caminhos
import '../../services/profile_service.dart';
import '../../widgets/profile_screen/info_panel.dart';
import '../../widgets/profile_screen/recipes_grid.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';
  final String userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  late Future<UserProfile> profileFuture;
  final ProfileService profileService = ProfileService();

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

  @override
  Widget build(BuildContext context) {
      // [MUDANÇA] O FutureBuilder agora constrói o Scaffold inteiro.
      return FutureBuilder<UserProfile>(
        future: profileFuture,
        builder: (context, snapshot) {
          // Estado de Carregamento
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Mostra um Scaffold simples enquanto carrega
            return Scaffold(
              appBar: AppBar(title: const Text('Carregando...')),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          // Estado de Erro
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Erro')),
              body: Center(
                child: Text(
                  'Erro: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          // Estado de Sucesso
          if (snapshot.hasData) {
            final profile = snapshot.data!;

            // [MUDANÇA] O Scaffold e a AppBar são construídos AQUI,
            // pois agora temos acesso ao objeto 'profile'.
            return Scaffold(
              appBar: AppBar(
                title: const Text('Perfil'),
              ),
              // O body é o mesmo layout de antes
              body: buildProfileLayout(context, profile),
            );
          }

          // Caso padrão
          return Scaffold(
            appBar: AppBar(title: const Text('Perfil')),
            body: const Center(child: Text('Nenhum perfil encontrado.')),
          );
        },
      );
    }

    // Constrói o layout principal da página
    // [MUDANÇA] Este método não foi alterado.
    Widget buildProfileLayout(BuildContext context, UserProfile profile) {
      // Altura do banner (30% da tela)
      final bannerHeight = MediaQuery.of(context).size.height * 0.3;

      // Ponto de início do InfoPanel (metade do avatar para cima,
      // a partir do fim do banner)
      // (Altura do Banner) - 60 (metade do avatar de 120)
      final infoPanelTopMargin = bannerHeight - 60;

      // O SingleChildScrollView agora engloba TUDO
      return SingleChildScrollView(
        child: Column(
          children: [
            // 1. O Stack para sobreposição
            // Este Stack agora está DENTRO da Column rolável.
            Stack(
              clipBehavior: Clip.none, // Permite o avatar "vazar"
              children: [
                // 1.a. O Banner (Filho 1, no fundo do Stack)
                // Não está mais "Positioned", é apenas um item no Stack
                Container(
                  height: bannerHeight,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/bg.jpg'), // Lembre-se dos assets
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // 1.b. O Painel de Informações (Filho 2, na frente do Stack)
                // Usamos uma Column com um SizedBox para "empurrar" o painel
                // para a posição correta sobre o banner.
                Column(
                  children: [
                    // Este SizedBox empurra o InfoPanel para baixo
                    SizedBox(height: infoPanelTopMargin),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: InfoPanel(
                        profile: profile,
                        seguidores: 0,
                        seguindo: 0,
                        posts: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // 2. O Painel de Receitas
            // Está na Column principal, APÓS o Stack.
            // O espaçamento agora é entre o Stack (InfoPanel) e este widget.
            Padding(
              padding: const EdgeInsets.only(
                top: 24.0, // Espaço entre o InfoPanel e o título "Receitas"
                left: 16.0,
                right: 16.0,
                bottom: 32.0, // Espaço no fim da rolagem
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
                  RecipesGrid(), // PainelReceitas
                ],
              ),
            )
          ],
        ),
      );
    }
  }