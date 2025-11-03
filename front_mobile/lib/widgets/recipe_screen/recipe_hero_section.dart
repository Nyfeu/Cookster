// lib/widgets/recipe_screen/recipe_hero_section.dart
import 'package:flutter/material.dart';
import '../../models/recipe_model.dart';
import '../../widgets/recipe_screen/recipe_icons_sidebar.dart';
import '../../widgets/recipe_screen/recipe_info_content.dart';
import '../../theme/recipe_theme.dart';

class RecipeHeroSection extends StatelessWidget {
  final Recipe recipe;
  const RecipeHeroSection({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    // .recipe-hero-container
    // O Wrap é a melhor tradução do seu 'display: flex' com 'flex-wrap: wrap'
    return Container(
      padding: const EdgeInsets.all(32), // 2rem
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: AppTheme.accent,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Wrap(
        spacing: 32, // gap: 2rem
        runSpacing: 32, // gap vertical quando quebra a linha
        alignment: WrapAlignment.center,
        children: [
          // Imagem
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              recipe.imageUrl,
              width: 500, // max-width: 500px
              height: 300,
              fit: BoxFit.cover,
              // Fallback em caso de erro
              errorBuilder: (context, error, stackTrace) => Image.asset(
                '../../assets/images/bolo.png', // <-- TROQUE PELO SEU CAMINHO
                width: 500,
                height: 300,
                fit: BoxFit.cover, // Garante que a imagem cubra o espaço
              )
            ),
          ),

          // .recipe-info
          // Constrain a largura para bater com o min-width e flex: 1
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 300, maxWidth: 400),
            child: RecipeInfoContent(recipe: recipe),
          ),

          // .recipe-icons-sidebar
          RecipeIconsSidebar(recipe: recipe),
        ],
      ),
    );
  }
}