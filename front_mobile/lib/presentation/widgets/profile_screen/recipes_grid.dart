import 'package:flutter/material.dart';
import '../../screens/recipe/recipe_screen.dart';

class RecipesGrid extends StatelessWidget {
  const RecipesGrid({super.key});

  final List<Map<String, String>> recipes = const [
    {'id': '68418757ea0cf6733b142a67', 'image': 'assets/images/Prato_1.webp'},
    {'id': '68418757ea0cf6733b142a68', 'image': 'assets/images/Prato_2.jpg'},
    {'id': '68430bc1181c530646ed2e92', 'image': 'assets/images/Prato_3.jpeg'},
    {'id': '68430c79181c530646ed2e93', 'image': 'assets/images/Prato_4.webp'},
    {'id': '690c3a21457837bb5cf42193', 'image': 'assets/images/Prato_5.jpg'},
    {'id': '690c3a21457837bb5cf42194', 'image': 'assets/images/Prato_6.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, 
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.2, 
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  RecipePage.routeName,
                  arguments: recipe['id']!,
                );
              },
              child: GridTile(
                footer: GridTileBar(
                  backgroundColor: Colors.black.withOpacity(0.6),
                  title: const Text(
                    'Ver Mais',
                    textAlign: TextAlign.center,
                  ),
                ),
                child: Image.asset(
                  recipe['image']!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}