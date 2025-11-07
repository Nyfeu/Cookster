import 'dart:async';
import 'package:flutter/material.dart';
import 'package:front_mobile/models/recipe_model.dart';
import 'package:front_mobile/providers/auth_provider.dart';
import 'package:front_mobile/providers/pantry_provider.dart';
import 'package:front_mobile/services/recipe_service.dart';
import 'package:front_mobile/widgets/search/recipe_list_item.dart';
import 'package:provider/provider.dart';
import 'package:front_mobile/theme/app_theme.dart';

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
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _pantryProvider = context.read<PantryProvider>();
    _pantryProvider.addListener(_onPantryChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSuggestedRecipes());
  }

  @override
  void dispose() {
    _pantryProvider.removeListener(_onPantryChanged);
    _debounce?.cancel();
    super.dispose();
  }

  void _onPantryChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      _loadSuggestedRecipes();
    });
  }

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

    setState(() {
      _emptyTitle = "Nenhuma sugestão";
      _emptyMessage = "Adicione itens à sua despensa para ver receitas!";
      _emptyImage = "assets/images/cesta.png";
      _suggestedRecipesFuture = recipeService.fetchSuggestedRecipes(token: token);
    });
  }

  Widget _buildTitlePanel(BuildContext context) {
    return Container(
      width: double.infinity, 
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05), //
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitlePanel(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
              child: FutureBuilder<List<Recipe>>(
                future: _suggestedRecipesFuture,
                builder: (context, snapshot) {
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
          ),
        ],
      ),
    );
  }
}