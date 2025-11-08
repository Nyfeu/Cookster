import 'package:flutter/material.dart';                   // Padrão do Flutter
import '../../../data/models/recipe_model.dart';          // Modelo de Receita
import '../../../data/services/recipe_service.dart';      // Serviço de Receita
import 'package:provider/provider.dart';                  // Pacote Provider
import '../../providers/auth_provider.dart';              // Provider de Autuenticação

// Tela de detalhamento da receita
// Permite visualizar os atributos como: descrição,
// tempo de preparo, passos, utensílios etc.

class RecipePage extends StatefulWidget {

  // Rota nomeada para receita
  static const String routeName = '/recipe';

  // ID da receita na página - informada via ModalRouter (vide 'main.dart')
  final String idReceita;

  const RecipePage({super.key, required this.idReceita});

  @override
  State<RecipePage> createState() => _RecipePageState();

}

class _RecipePageState extends State<RecipePage> {

  // Usa Future para informações obtidas assíncronamente
  // pelo API-GATEWAY para a receita

  late Future<Recipe> _recipeFuture;
  
  // Variável para armazenar o token necessário para acessar as 
  // rotas protegidas - recuperará através do Provider

  String? _token;
  
  // Serviço para acesso à camada de dados de receitas

  final RecipeService _recipeService = RecipeService();

  // Estado inicial

  @override
  void initState() {
    super.initState();

    // Recupera o token via AuthProvider
    _token = Provider.of<AuthProvider>(context, listen: false).token;

    if (_token != null) {
      _recipeFuture = _recipeService.fetchRecipe(widget.idReceita, _token!);
    }

  }

  @override
  Widget build(BuildContext context) {
    if (_token == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cookster'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 24),
              Text(
                'Ops! Login Necessário',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Você precisa estar logado para ver os detalhes desta receita.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.4),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
      body: FutureBuilder<Recipe>(
        future: _recipeFuture,
        builder: (context, snapshot) {

          // 'snapshot' serve para monitorar o estado do Future
          // e atualizar a UI conforme necessário

          // Mostra indicador de carregamento enquanto espera

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Mostra mensagem de erro se ocorrer um problema

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            );
          }

          // Mostra mensagem de estado vazio se não houver dados da receita

          if (!snapshot.hasData) {
            return const Center(child: Text('Receita não encontrada.'));
          }

          // Armazena os dados da receita a partir da snapshot

          final recipe = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RecipeHeroSection(recipe: recipe),

                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {

                      // Verifica o tamanho da tela para responsividade
                      // No caso, a largura da tela - verificando se
                      // é ou não Desktop

                      bool isDesktop = constraints.maxWidth > 768;

                      if (isDesktop) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: _InstructionsInfo(steps: recipe.steps),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  _IngredientsInfo(
                                      ingredients: recipe.ingredients),
                                  const SizedBox(height: 24),
                                  _ToolsInfo(utensils: recipe.utensils),
                                ],
                              ),
                            ),
                          ],
                        );
                      } else {
                        // Mobile:
                        return Column(
                          children: [
                            _IngredientsInfo(ingredients: recipe.ingredients),
                            const SizedBox(height: 24),
                            _ToolsInfo(utensils: recipe.utensils),
                            const SizedBox(height: 24),
                            _InstructionsInfo(steps: recipe.steps),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Widgets gerais para a página de receita

class _RecipeHeroSection extends StatelessWidget {
  final Recipe recipe;
  const _RecipeHeroSection({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final Widget fallbackImage = Image.asset(
      'assets/images/bolo.png',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: const Icon(
            Icons.broken_image,
            size: 50,
            color: Colors.grey,
          ),
        );
      },
    );

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: 400,
          width: double.infinity,
          child: recipe.imageUrl.isNotEmpty
              ? Image.network(
                  recipe.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return fallbackImage;
                  },
                )
              : fallbackImage,
        ),

        Container(
          height: 400,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.8),
              ],
              stops: const [0.5, 0.7, 1.0],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                recipe.name,
                style: textTheme.headlineLarge
                    ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Por ${recipe.userId}',
                style: textTheme.titleMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _InfoChip(
                    icon: Icons.timer_outlined,
                    label: '${recipe.prepTime} min',
                  ),
                  _InfoChip(
                    icon: Icons.restaurant_menu_outlined,
                    label: '${recipe.servings} porções',
                  ),
                  _InfoChip(
                    icon: Icons.star_outline,
                    label: '4.5 (22)',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InstructionsInfo extends StatelessWidget {
  final List<String> steps;
  const _InstructionsInfo({required this.steps});

  @override
  Widget build(BuildContext context) {
    return _StyledCard(
      title: 'Modo de Preparo',
      child: ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: steps.length,
        separatorBuilder: (context, index) => Divider(color: Colors.grey[300]),
        itemBuilder: (context, index) {
          return _StepTile(
            stepNumber: index + 1,
            instruction: steps[index],
          );
        },
      ),
    );
  }
}

class _IngredientsInfo extends StatelessWidget {
  final List<Ingredient> ingredients;
  const _IngredientsInfo({required this.ingredients});

  @override
  Widget build(BuildContext context) {
    return _StyledCard(
      title: 'Ingredientes',
      child: Column(
        children: ingredients.map((ingredient) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_outline,
                    color: Theme.of(context).primaryColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${ingredient.quantity} ${ingredient.unit} - ${ingredient.name}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ToolsInfo extends StatelessWidget {
  final List<String> utensils;
  const _ToolsInfo({required this.utensils});

  @override
  Widget build(BuildContext context) {
    if (utensils.isEmpty) {
      return const SizedBox.shrink();
    }

    return _StyledCard(
      title: 'Utensílios',
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: utensils.map((tool) {
          return Chip(
            avatar: Icon(Icons.kitchen_outlined, color: Colors.grey[700]),
            label: Text(tool),
            backgroundColor: Colors.grey[200],
          );
        }).toList(),
      ),
    );
  }
}

class _StyledCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _StyledCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }
}

class _StepTile extends StatelessWidget {
  final int stepNumber;
  final String instruction;

  const _StepTile({required this.stepNumber, required this.instruction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              '$stepNumber',
              style:
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              instruction,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}