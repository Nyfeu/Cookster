// lib/widgets/recipe_info_content.dart
import 'package:flutter/material.dart';
import '../../models/recipe_model.dart';
import '../../theme/recipe_theme.dart';

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
        Text(recipe.name, style: textTheme.headlineMedium),
        // <Link> .user-link
        TextButton(
          onPressed: () {
            print('Navegar para perfil: ${recipe.userId}');
            // Ex: Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(userId: recipe.userId)));
          },
          child: Text(recipe.userId),
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