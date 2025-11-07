import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../services/profile_service.dart';
import '../../widgets/profile_screen/info_panel.dart';
import '../../widgets/profile_screen/recipes_grid.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';
  final String userId;
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
    return FutureBuilder<UserProfile>(
      future: profileFuture,
      builder: (context, snapshot) {

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
            clipBehavior: Clip.none,
            children: [

              Container(
                height: bannerHeight,
                width: double.infinity,
                decoration: const BoxDecoration(
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