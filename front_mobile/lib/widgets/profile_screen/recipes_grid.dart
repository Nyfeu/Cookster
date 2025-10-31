// [NOVO] Importe a tela de receita para ter acesso ao 'routeName'
import 'package:flutter/material.dart';
import '../../screens/recipe/recipe_screen.dart'; 

class RecipesGrid extends StatelessWidget {
  const RecipesGrid({super.key});

  // Lista de receitas (hardcoded como no seu exemplo)
  final List<Map<String, String>> recipes = const [
    {'id': '68418757ea0cf6733b142a67', 'image': 'assets/images/Prato_1.jpeg'},
    {'id': '68418757ea0cf6733b142a67', 'image': 'assets/images/Prato_2.jpg'},
    {'id': '68418757ea0cf6733b142a67', 'image': 'assets/images/Prato_3.jpg'},
    {'id': '68418757ea0cf6733b142a67', 'image': 'assets/images/Prato_1.jpeg'},
    {'id': '68418757ea0cf6733b142a67', 'image': 'assets/images/Prato_2.jpg'},
    {'id': '68418757ea0cf6733b142a67', 'image': 'assets/images/Prato_3.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    // GridView substitui o 'display: grid'
    return GridView.builder(
      // Importante: Desativa o scroll do GridView,
      // pois a tela principal (SingleChildScrollView) já faz o scroll.
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 colunas no mobile
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.2, // Proporção da imagem (largura / altura)
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        
        // [REMOVIDO] O GestureDetector não é necessário,
        // pois o InkWell já cuida do toque e da animação.
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Colors.transparent, // Necessário para o InkWell funcionar
            child: InkWell(
              onTap: () {
                // [NOVO] Lógica de navegação para a tela da receita
                Navigator.pushNamed(
                  context,
                  RecipePage.routeName,
                  arguments: recipe['id']!, // Passa o ID da receita clicada
                );
              },
              child: GridTile(
                // O restante do seu código permanece igual
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