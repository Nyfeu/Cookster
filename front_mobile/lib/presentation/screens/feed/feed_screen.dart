import 'dart:async';                                                                 // Permite o uso de Timer
import 'package:flutter/material.dart';                                              // Importa o Flutter Material
import 'package:front_mobile/data/models/recipe_model.dart';                         // Importa o modelo de dados Recipe
import 'package:front_mobile/presentation/providers/auth_provider.dart';             // Importa o AuthProvider
import 'package:front_mobile/presentation/providers/pantry_provider.dart';           // Importa o PantryProvider
import 'package:front_mobile/data/services/recipe_service.dart';                     // Importa o RecipeService
import 'package:front_mobile/presentation/widgets/search/recipe_list_item.dart';     // Importa o widget RecipeListItem
import 'package:provider/provider.dart';                                             // Importa o Provider para gerenciamento de estado
import 'package:front_mobile/core/theme/app_theme.dart';                             // Importa o tema da aplicação

// Tela de Feed de Receitas Sugeridas
// Mostra receitas sugeridas com base nos itens da despensa do usuário
// Utiliza PantryProvider para monitorar mudanças na despensa
// e recarregar as sugestões automaticamente
// Utiliza RecipeService para buscar as receitas sugeridas da API

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {

  // Future para carregar receitas sugeridas
  // Atualizado quando a despensa muda
  // Usa Future pois a busca é assíncrona e pode demorar

  Future<List<Recipe>>? _suggestedRecipesFuture;

  // Mensagens padrão para estado vazio

  String _emptyTitle = "Nenhuma sugestão";
  String _emptyMessage = "Adicione itens à sua despensa para ver receitas!";
  String _emptyImage = "assets/images/cesta.png";

  // Referência ao PantryProvider para monitorar mudanças na despensa

  late final PantryProvider _pantryProvider;

  // Timer para debounce ao recarregar sugestões (espera a sincronização entre os
  // microsserviços): mss-pantry e mss-recipe.

  Timer? _debounce;

  // Inicialização do estado

  @override
  void initState() {
    super.initState();
    _pantryProvider = context.read<PantryProvider>();
    _pantryProvider.addListener(_onPantryChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSuggestedRecipes());
  }

  // Limpeza dos listeners e timers

  @override
  void dispose() {
    _pantryProvider.removeListener(_onPantryChanged);
    _debounce?.cancel();
    super.dispose();
  }

  // Chamado quando a despensa muda

  void _onPantryChanged() {

    // Usa debounce para evitar múltiplas chamadas rápidas
    // Espera 800ms após a última mudança para recarregar as sugestões
    // Isso ajuda a garantir que os dados estejam sincronizados

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      _loadSuggestedRecipes();
    });
  }

  // Carrega receitas sugeridas

  void _loadSuggestedRecipes() {
    if (!mounted) {
      return;
    }

    // Obtém token e serviço via Provider

    final token = context.read<AuthProvider>().token;

    // Usa RecipeService para buscar receitas sugeridas
    // Atualiza o Future para disparar o rebuild da UI

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

  // Constrói o painel de título da tela

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

  // Constrói a UI da tela do Feed

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
                future: _suggestedRecipesFuture,   // Future que carrega as receitas sugeridas
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

                  // Mostra mensagem de estado vazio se não houver sugestões

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

                  // Mostra a lista de receitas sugeridas

                  final recipes = snapshot.data!;

                  // ListView.builder é usado para listas grandes e dinâmicas
                  // Constrói apenas os itens visíveis para melhor performance
                  // Cada item é um RecipeListItem (retorna um Card) que mostra os detalhes da receita
                  // Conforme: https://api.flutter.dev/flutter/widgets/ListView-class.html

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