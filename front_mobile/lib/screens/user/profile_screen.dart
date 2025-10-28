import 'package:flutter/material.dart';
import '../../models/user_profile.dart'; // Ajuste caminhos
import '../../services/profile_service.dart';
import '../../widgets/profile_screen/info_panel.dart';
import '../../widgets/profile_screen/recipes_grid.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';
  final String userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserProfile> _profileFuture;
  final ProfileService _profileService = ProfileService();

  // Simulação do ID do usuário logado (localStorage.getItem('user').id)
  final String _currentUserId = '12345'; // Mude para o ID do usuário logado

  @override
  void initState() {
    super.initState();
    _profileFuture = _profileService.fetchUserProfile(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    bool isCurrentUser = (widget.userId == _currentUserId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'), // Substitui NavBar_Auth
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: isCurrentUser
                ? IconButton(
                    icon: const Icon(Icons.settings), // Ícone de engrenagem
                    onPressed: () {
                      // Navegar para Configurações
                      // Ex: Navigator.push(context, MaterialPageRoute(builder: (c) => SettingsScreen()));
                    },
                  )
                : ElevatedButton(
                    onPressed: () {
                      // Lógica de "Seguir"
                    },
                    child: const Text('Seguir'),
                  ),
          ),
        ],
      ),
      body: FutureBuilder<UserProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          // Estado de Carregamento
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Estado de Erro
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // Estado de Sucesso
          if (snapshot.hasData) {
            final profile = snapshot.data!;
            return buildProfileLayout(context, profile);
          }

          // Caso padrão (nunca deve acontecer se o future for válido)
          return const Center(child: Text('Nenhum perfil encontrado.'));
        },
      ),
    );
  }
  // Constrói o layout principal da página
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