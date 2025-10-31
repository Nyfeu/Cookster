// lib/widgets/recipe_screen/ingredients_info.dart
import 'package:flutter/material.dart';
import '../../models/recipe_model.dart';
import '../../widgets/recipe_screen/single_ingredient.dart';
import '../../widgets/recipe_screen/styled_card.dart';

class IngredientsInfo extends StatelessWidget {
  final List<Ingredient> ingredients;
  const IngredientsInfo({super.key, required this.ingredients});

  @override
  Widget build(BuildContext context) {
    // .second-column > div
    return StyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // <h4>
          Text(
            'Ingredientes',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(
            height: 16
            ), // 1rem
          
          // .ingredient-list
          // ListView.builder não funciona bem dentro de outro scroll
          // Usamos uma Coluna simples
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: ingredients.map((ingredient) {
              return SingleIngredient(ingredient: ingredient);
            }).toList(),
          ),
        ],
      ),
    );
  }
}