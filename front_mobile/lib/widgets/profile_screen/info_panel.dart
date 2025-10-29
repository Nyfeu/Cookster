import 'package:flutter/material.dart';
import '../../models/user_profile.dart'; // Ajuste o caminho

class InfoPanel extends StatelessWidget {
  final UserProfile profile;
  final int seguidores;
  final int seguindo;
  final int posts;

  const InfoPanel({
    super.key,
    required this.profile,
    required this.seguidores,
    required this.seguindo,
    required this.posts,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // O Stack é necessário para posicionar o avatar 'flutuando'
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // O card de conteúdo (começa 60px abaixo do topo)
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 60),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Espaço vazio para a metade de baixo do avatar
              const SizedBox(height: 60),

              // Informações
              Text(profile.name, style: textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(profile.bio, style: textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(profile.email, style: textTheme.bodySmall),
              const SizedBox(height: 20),

              // Estatísticas (ul.about)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn('Seguidores', seguidores),
                  _buildStatColumn('Seguindo', seguindo),
                  _buildStatColumn('Posts', posts),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),

              // Descrição (div.content)
              Text(
                profile.descricao,
                textAlign: TextAlign.justify,
                style: textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF1D1D1D), // Cor específica do CSS
                  height: 1.8, // line-height
                ),
              ),
            ],
          ),
        ),

        // O Avatar (position: absolute, top: -60px)
        Positioned(
          top: 0,
          child: _buildAvatar(context),
        ),
      ],
    );
  }

  // Avatar com funcionalidade de zoom ao clicar
  Widget _buildAvatar(BuildContext context) {
    final imageProvider = const AssetImage('assets/images/default-profile.jpeg');

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => Dialog(
            child: InteractiveViewer( // Permite zoom com os dedos
              child: Image(image: imageProvider),
            ),
          ),
        );
      },
      child: CircleAvatar(
        radius: 60,
        backgroundImage: imageProvider,
        backgroundColor: Colors.grey[200],
      ),
    );
  }

  // Helper para criar as colunas de estatísticas
  Widget _buildStatColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF4D6B5B), // text-color
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF818181),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}