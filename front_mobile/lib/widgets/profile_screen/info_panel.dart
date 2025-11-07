import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../screens/user/edit_screen.dart';

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

    return Stack(
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
                      onPressed: () {
                        
                        Navigator.pushNamed(
                          context,
                          EditProfileScreen.routeName,
                          arguments: profile.id, 
                        );
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