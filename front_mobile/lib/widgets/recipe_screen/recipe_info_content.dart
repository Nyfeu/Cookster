// lib/widgets/recipe_info_content.dart
import 'package:flutter/material.dart';
import '../../models/recipe_model.dart';
import '../../theme/recipe_theme.dart';
import '../../screens/user/profile_screen.dart';

class RecipeInfoContent extends StatelessWidget {
  final Recipe recipe;
  const RecipeInfoContent({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // align-items:flex-start
      children: [
        // <h2>
        Center( // Adicionado o widget Center aqui
          child: Text(recipe.name, 
          style: textTheme.headlineMedium,
          textAlign: TextAlign.center,),
        ),

        Center( // Adicionado o widget Center aqui
          child: TextButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                ProfileScreen.routeName,
                arguments: recipe.userId // Passa o ID do usuário para a rota
              );
            },
            child: Text("Perfil do Autor"),
          ),
        ),
        const SizedBox(height: 10),
        // <p> (descrição)
        Text(recipe.description, style: textTheme.bodyLarge),
        const SizedBox(height: 32), // 20rem de margin-top era muito?
        // .recipe-tags
        Wrap(
          spacing: 8.0, // margin-right: 0.5rem
          runSpacing: 4.0,
          children: recipe.tags.map((tag) {
            return Chip(
              label: Text(tag),
              backgroundColor: AppTheme.accent.withOpacity(0.2),
            );
          }).toList(),
        ),
      ],
    );
  }
}