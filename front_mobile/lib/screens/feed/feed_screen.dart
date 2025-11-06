import 'dart:async'; // 1. Importe o 'dart:async' para usar o Timer
import 'package:flutter/material.dart';
import 'package:front_mobile/models/recipe_model.dart';
import 'package:front_mobile/providers/auth_provider.dart';
import 'package:front_mobile/providers/pantry_provider.dart';
import 'package:front_mobile/services/recipe_service.dart';
import 'package:front_mobile/widgets/search/recipe_list_item.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  Future<List<Recipe>>? _suggestedRecipesFuture;

  String _emptyTitle = "Nenhuma sugestão";
  String _emptyMessage = "Adicione itens à sua despensa para ver receitas!";
  String _emptyImage = "assets/images/cesta.png";

  late final PantryProvider _pantryProvider;
  Timer? _debounce; // 2. Adicione a variável do Timer

  @override
  void initState() {
    super.initState();
    _pantryProvider = context.read<PantryProvider>();

    // 3. Em vez de chamar _loadSuggestedRecipes, chame a função de debounce
    _pantryProvider.addListener(_onPantryChanged);

    // Carregamento inicial (pode ser feito direto ou com o debounce)
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSuggestedRecipes());
  }

  @override
  void dispose() {
    _pantryProvider.removeListener(_onPantryChanged);
    _debounce?.cancel(); // 4. Cancele o timer ao sair da tela
    super.dispose();
  }

  // 5. Esta é a nova função de "debounce"
  void _onPantryChanged() {
    // Se já existir um timer ativo, cancele-o
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Crie um novo timer. A função _loadSuggestedRecipes só será
    // chamada após 800ms *sem* novas mudanças na despensa.
    _debounce = Timer(const Duration(milliseconds: 800), () {
      _loadSuggestedRecipes();
    });
  }

  // 6. _loadSuggestedRecipes não precisa de 'async' e 
  //    só é chamada quando o timer termina
  void _loadSuggestedRecipes() {
    if (!mounted) {
      return;
    }

    final token = context.read<AuthProvider>().token;
    final recipeService = context.read<RecipeService>();

    if (token == null) {
      setState(() {
        _emptyTitle = "Ops! Faça login";
        _emptyMessage = "Você precisa estar logado para ver suas sugestões.";
        _emptyImage = 'assets/images/log.png';
        _suggestedRecipesFuture = Future.value([]);
      });
      return;
    }

    // Esta chamada de setState é a que atualiza o FutureBuilder
    setState(() {
      _emptyTitle = "Nenhuma sugestão";
      _emptyMessage = "Adicione itens à sua despensa para ver receitas!";
      _emptyImage = "assets/images/cesta.png";
      _suggestedRecipesFuture = recipeService.fetchSuggestedRecipes(token: token);
    });
  }

  @override
  Widget build(BuildContext context) {
    // O build permanece idêntico, sem o Consumer
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Receitas que você pode fazer',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'Com base nos itens da sua despensa.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Recipe>>(
                future: _suggestedRecipesFuture,
                builder: (context, snapshot) {
                  // ... (Todo o resto do seu FutureBuilder permanece igual)
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/log.png', height: 160),
                            const SizedBox(height: 24),
                            Text(
                              "Erro ao carregar sugestões",
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Não foi possível conectar ao servidor.\nTente novamente mais tarde.",
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(_emptyImage, height: 160),
                            const SizedBox(height: 24),
                            Text(
                              _emptyTitle,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _emptyMessage,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final recipes = snapshot.data!;
                  return ListView.builder(
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      return RecipeListItem(recipe: recipes[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}