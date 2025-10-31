// lib/widgets/recipe_icons_sidebar.dart
import 'package:flutter/material.dart';
import '../../models/recipe_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/recipe_theme.dart';

class RecipeIconsSidebar extends StatelessWidget {
  final Recipe recipe;
  const RecipeIconsSidebar({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    // .recipe-icons-sidebar
    return Container(
      width: 200, // width: 200px
      padding: const EdgeInsets.all(24), // 1.5rem
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIconInfo(
            icon: FontAwesomeIcons.clock, // fas fa-clock
            title: 'Tempo de Preparação',
            value: '${recipe.prepTime} min',
          ),
          const SizedBox(height: 24), // 1.5rem gap
          _buildIconInfo(
            icon: FontAwesomeIcons.solidClock, // far fa-clock
            title: 'Tempo de Cozimento',
            value: '${recipe.cookTime} min',
          ),
          const SizedBox(height: 24), // 1.5rem gap
          _buildIconInfo(
            icon: FontAwesomeIcons.userFriends, // fas fa-user-friends
            title: 'Porção',
            value: '${recipe.servings} porções',
          ),
        ],
      ),
    );
  }

  // <article>
  Widget _buildIconInfo(
      {required IconData icon, required String title, required String value}) {
    return Column(
      children: [
        // <i>
        FaIcon(icon, size: 28, color: AppTheme.text), // 1.8rem
        const SizedBox(height: 8), // 0.5rem
        // <h5>
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16, // 1rem
            color: AppTheme.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5), // 0.3rem
        // <p>
        Text(
          value,
          style: const TextStyle(
            fontSize: 17, // 1.1rem
            fontWeight: FontWeight.bold,
            color: Color(0xFF555555),
          ),
        ),
      ],
    );
  }
}