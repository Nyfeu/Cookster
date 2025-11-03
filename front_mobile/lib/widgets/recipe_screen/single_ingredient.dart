// lib/widgets/single_ingredient.dart
import 'package:flutter/material.dart';
import '../../models/recipe_model.dart';
import '../../theme/recipe_theme.dart';

class SingleIngredient extends StatelessWidget {
  final Ingredient ingredient;
  const SingleIngredient({super.key, required this.ingredient});

  @override
  Widget build(BuildContext context) {
    // <li> e .single-ingredient
    // Uma Row com Icon e Text simula sua lista <li>
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ::marker
          const Padding(
            padding: EdgeInsets.only(top: 6.0, right: 8.0),
            child: Icon(Icons.circle, size: 8, color: AppTheme.secondary),
          ),
          // <p>
          Expanded(
            child: Text(
              '${ingredient.quantity} ${ingredient.unit} de ${ingredient.name}'
              '${ingredient.note != null ? ' (${ingredient.note})' : ''}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}