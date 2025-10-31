import 'package:flutter/material.dart';

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
        
        // GestureDetector substitui o <a> (link)
        return GestureDetector(
          onTap: () {
            // Lógica de navegação para a tela da receita
            print('Navegar para receita: ${recipe['id']}');
            // Ex: Navigator.push(context, MaterialPageRoute(builder: (c) => RecipeScreen(id: recipe['id'])));
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Material(
              color: Colors.transparent, // Necessário para o InkWell funcionar
              child: InkWell(
                onTap: () {
                  // Lógica de navegação (a mesma que você tinha)
                  print('Navegar para receita: ${recipe['id']}');
                  // Ex: Navigator.push(context, MaterialPageRoute(builder: (c) => RecipeScreen(id: recipe['id'])));
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
          ),
        );
      },
    );
  }
}