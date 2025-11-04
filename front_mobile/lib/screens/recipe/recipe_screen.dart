// lib/pages/recipe_page.dart
import 'package:flutter/material.dart';
import '../../models/recipe_model.dart';
import '../../services/recipe_service.dart';
import '../../widgets/recipe_screen/recipe_hero_section.dart';
import '../../widgets/recipe_screen/instructions_info.dart';
import '../../widgets/recipe_screen/ingredients_info.dart';
import '../../widgets/recipe_screen/tools_info.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RecipePage extends StatefulWidget {
  static const String routeName = '/recipe';
  final String idReceita; // Recebe o ID (como o useParams)

  const RecipePage({super.key, required this.idReceita});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  // O Future armazena o estado da requisição (loading, data, error)
  late Future<Recipe> _recipeFuture;
  final RecipeService _recipeService = RecipeService();

  @override
  void initState() {
    super.initState();
    
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    if (token != null) {
      _recipeFuture = _recipeService.fetchRecipe(widget.idReceita, token);
    } else {
      // Se não há token, o Future já retorna um erro.
      _recipeFuture = Future.error('Usuário não autenticado. Token nulo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold é a base da página
    return Scaffold(
      // Seu <NavBar_Auth />
      appBar: AppBar(
        title: const Text('Cookster'),
      ),
      // FutureBuilder gerencia os estados de loading/error/data
      body: FutureBuilder<Recipe>(
        future: _recipeFuture,
        builder: (context, snapshot) {
          // if (loading)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // if (error)
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 18),
              ),
            );
          }

          // if (!recipeData)
          if (!snapshot.hasData) {
            return const Center(child: Text('Receita não encontrada.'));
          }

          // Sucesso! Temos os dados.
          final recipe = snapshot.data!;

          // Seu return <div> ... </div>
          // SingleChildScrollView permite rolar a página
          return SingleChildScrollView(
            // Padding do seu .page
            padding: const EdgeInsets.all(32.0), // 2rem
            child: Column(
              children: [
                // <section className="recipe-hero">
                RecipeHeroSection(recipe: recipe),

                const SizedBox(height: 32), // 2rem gap

                // <section className="recipe-content">
                // LayoutBuilder para o grid responsivo
                LayoutBuilder(
                  builder: (context, constraints) {
                    bool isDesktop = constraints.maxWidth > 768;

                    if (isDesktop) {
                      // Grid 2fr 1fr
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Coluna 1 (Instruções)
                          Expanded(
                            flex: 2, // 2fr
                            child: InstructionsInfo(steps: recipe.steps),
                          ),
                          const SizedBox(width: 32), // 2rem gap
                          // Coluna 2 (Ingredientes e Utensílios)
                          Expanded(
                            flex: 1, // 1fr
                            child: Column(
                              children: [
                                IngredientsInfo(ingredients: recipe.ingredients),
                                const SizedBox(height: 16), // 1rem
                                ToolsInfo(utensils: recipe.utensils),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Mobile: Grid 1fr (coluna única)
                      return Column(
                        children: [
                          InstructionsInfo(steps: recipe.steps),
                          const SizedBox(height: 32), // 2rem
                          IngredientsInfo(ingredients: recipe.ingredients),
                          const SizedBox(height: 16), // 1rem
                          ToolsInfo(utensils: recipe.utensils),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}