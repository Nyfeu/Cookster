// lib/screens/feed/feed_screen.dart

import 'package:flutter/material.dart';
import 'package:front_mobile/providers/pantry_provider.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late PantryProvider _pantryProvider;
  bool _isInitialLoad = true;
  
  // Aqui você guardaria as receitas buscadas
  // List<Recipe> _recipes = []; 
  // bool _isRecipesLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Obtém o provider
    _pantryProvider = Provider.of<PantryProvider>(context);

    if (_isInitialLoad) {
      // Carrega os ingredientes da despensa (e notifica os listeners)
      _pantryProvider.fetchIngredientes();
      _isInitialLoad = false;
    }
    
    // Adiciona o listener para futuras mudanças (feitas na PantryScreen)
    _pantryProvider.addListener(_onPantryChange);

    // Busca receitas imediatamente
    _fetchRecipes();
  }

  @override
  void dispose() {
    // Limpa o listener
    _pantryProvider.removeListener(_onPantryChange);
    super.dispose();
  }

  void _onPantryChange() {
    // A despensa mudou! Busca novas receitas.
    print("Despensa atualizada, buscando novas receitas...");
    _fetchRecipes();
  }

  Future<void> _fetchRecipes() async {
    // setState(() { _isRecipesLoading = true; });

    // Pega os ingredientes atuais do provider
    final ingredientesAtuais = _pantryProvider.ingredientes;
    
    print("Buscando receitas para ${ingredientesAtuais.length} ingredientes.");

    /*
    // ===================================================================
    // AQUI É ONDE VOCÊ CHAMA SEU SERVICE DE RECEITAS (ex: mss-recipe)
    //
    // try {
    //   final newRecipes = await RecipeService.getRecipesForPantry(ingredientesAtuais);
    //   if (mounted) {
    //     setState(() {
    //       _recipes = newRecipes;
    //       _isRecipesLoading = false;
    //     });
    //   }
    // } catch (e) {
    //   if (mounted) setState(() { _isRecipesLoading = false; });
    //   print("Erro ao buscar receitas: $e");
    // }
    // ===================================================================
    */
    
    // Por enquanto, vamos apenas forçar a rebuild da tela para mostrar
    // que a atualização foi recebida.
    if (mounted) {
      setState(() {
         // Esta linha força a atualização do widget
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos o Consumer aqui para que o build seja chamado
    // quando _fetchRecipes() chamar setState()
    return Consumer<PantryProvider>(
      builder: (context, provider, child) {
        
        // if (_isRecipesLoading && _recipes.isEmpty) {
        //   return Center(child: CircularProgressIndicator());
        // }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Receitas para você', 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 10),
              Text('Baseado em ${provider.ingredientes.length} ingredientes na sua despensa.'),
              const Divider(height: 30),
              
              // AQUI VOCÊ RENDERIZA A LISTA DE RECEITAS (_recipes)
              // Por enquanto, vamos exibir os ingredientes para provar que funciona:
              Expanded(
                child: provider.ingredientes.isEmpty
                  ? const Text("Adicione ingredientes na Despensa para ver receitas.")
                  : ListView.builder(
                      itemCount: provider.ingredientes.length,
                      itemBuilder: (context, index) {
                        final ing = provider.ingredientes[index];
                        return Card(
                          child: ListTile(
                            title: Text(ing.nome),
                            subtitle: Text(ing.categoria),
                          ),
                        );
                      },
                    ),
              )
            ],
          ),
        );
      },
    );
  }
}