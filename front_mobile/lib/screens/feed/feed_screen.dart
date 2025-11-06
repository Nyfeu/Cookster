// [NOVO ARQUIVO OU ARQUIVO MODIFICADO]
// lib/screens/home/feed_screen.dart (ou onde quer que seu FeedScreen esteja)

import 'package:flutter/material.dart';
import 'package:front_mobile/models/recipe_model.dart';
import 'package:front_mobile/providers/auth_provider.dart';
import 'package:front_mobile/services/recipe_service.dart';
import 'package:front_mobile/widgets/search/recipe_list_item.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late Future<List<Recipe>> _suggestedRecipesFuture;
  
  // --- NOSSAS NOVAS VARIÁVEIS DE ESTADO ---
  String _emptyMessage = "Adicione itens à sua despensa para ver receitas!";
  String _emptyTitle = "Nenhuma sugestão";
  String _emptyImage = 'assets/images/cesta.png'; //
  bool _isInit = true; // Flag para garantir que o load só rode uma vez

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Usamos didChangeDependencies em vez de initState
    // para poder acessar os Providers com segurança
    if (_isInit) {
      _loadSuggestedRecipes();
      _isInit = false;
    }
  }

  void _loadSuggestedRecipes() {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final recipeService = Provider.of<RecipeService>(context, listen: false);

    if (token == null) {
      // Se não há token, mudamos as mensagens de "estado vazio"
      // E definimos o futuro como uma lista vazia, em vez de um erro.
      setState(() {
        _emptyTitle = "Ops! Faça login";
        _emptyMessage = "Você precisa estar logado para ver suas sugestões.";
        _emptyImage = 'assets/images/log.png'; //
        _suggestedRecipesFuture = Future.value([]); // <-- A MUDANÇA PRINCIPAL
      });
      return;
    }

    // Se há token, configuramos as mensagens padrão e buscamos os dados
    setState(() {
      _emptyTitle = "Nenhuma sugestão";
      _emptyMessage = "Adicione itens à sua despensa para ver receitas!";
      _emptyImage = 'assets/images/cesta.png'; //
      
      // Define o futuro para buscar as receitas
      _suggestedRecipesFuture =
          recipeService.fetchSuggestedRecipes(token: token);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  // Estado de Carregamento
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Estado de Erro (agora só para erros REAIS de rede/API)
                  if (snapshot.hasError) {
                    // Mostra o mesmo layout amigável usado para "sem dados"
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/log.png', // você pode criar uma imagem específica de erro
                              height: 160,
                            ),
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
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Estado de Sucesso (vazio)
                  // Isso agora trata tanto "não logado" quanto "sem receitas"
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              _emptyImage, // Imagem dinâmica
                              height: 160,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _emptyTitle, // Título dinâmico
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _emptyMessage, // Mensagem dinâmica
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Estado de Sucesso (com dados)
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