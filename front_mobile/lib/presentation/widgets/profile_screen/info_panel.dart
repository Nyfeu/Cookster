import 'package:flutter/material.dart';            // Flutter Padrão
import '../../../data/models/user_profile.dart';   // Modelo de Usuário
import '../../screens/user/edit_screen.dart';      // Tela de Edição do Perfil do Usuário 

class InfoPanel extends StatelessWidget {

  // Variáveis para informações dos dados de usuário

  final UserProfile profile;
  final int seguidores;
  final int seguindo;
  final int posts;
  final VoidCallback? onProfileUpdated;

  const InfoPanel({
    super.key,
    required this.profile,
    required this.seguidores,
    required this.seguindo,
    required this.posts,
    this.onProfileUpdated,
  });

  @override
  Widget build(BuildContext context) {

    // Recupera o tema do aplicativo
    final textTheme = Theme.of(context).textTheme;

    return Stack(

      // Stack é usado para permitir que widgets sejam desenhados um sobre o outro (empilhados), 
      // em vez de apenas em sequência vertical/horizontal. Principais motivos para usar 
      // Stack aqui. Conforme: https://api.flutter.dev/flutter/widgets/Stack-class.html

      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
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
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 60),
                  Text(profile.name, style: textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(profile.bio, style: textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(profile.email, style: textTheme.bodySmall),
                  const SizedBox(height: 20),
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

                  Text(
                    profile.descricao,
                    textAlign: TextAlign.justify,
                    style: textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF1D1D1D),
                     height: 1.8,
                    ),
                  ),
                ],
              ),

              Positioned(
                top: 0,
                right: 0,
                child: profile.isOwner
                  ? IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          EditProfileScreen.routeName,
                          arguments: profile.id,
                        );
                        if (result == true) {
                          onProfileUpdated?.call();
                        }
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
        ),

       Positioned(
          top: 0,
          child: _buildAvatar(context),
        ),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final imageProvider = const AssetImage('assets/images/default-profile.jpeg');

    // Usamos GestureDetector para capturar gestos (ex: onTap, onLongPress) sobre esta área.
    // Motivos principais:
    //
    // 1) Precisamos reagir a toques em uma região que não é, obrigatoriamente, um botão padrão
    //    — por exemplo, para fechar o painel, ocultar o teclado (FocusScope.of(context).unfocus())
    //    ou abrir/fechar seções via toque.
    //
    // 2) GestureDetector não exige um ancestor Material, ao contrário de InkWell/InkResponse,
    //    então funciona mesmo quando não há um widget Material na hierarquia.
    //
    // 3) Ele fornece apenas eventos de gesto sem feedback visual automático (sem ripple),
    //    útil quando não se quer alterar a aparência. Se precisar de feedback visual, use InkWell
    //    dentro de um Material.
    //

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => Dialog(
            child: InteractiveViewer(
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

  Widget _buildStatColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
             fontWeight: FontWeight.w600,
              color: Color(0xFF4D6B5B),
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