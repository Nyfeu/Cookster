import 'package:flutter/material.dart';
import 'package:front_mobile/models/recipe_model.dart';
import 'package:front_mobile/providers/auth_provider.dart';
import 'package:front_mobile/services/recipe_service.dart';
import 'package:front_mobile/theme/app_theme.dart';
import 'package:front_mobile/widgets/search/recipe_list_item.dart';
import 'package:provider/provider.dart';

// Enum para controlar o tipo de busca
enum SearchType { porNome, porAutor }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _recipeService = RecipeService();

  List<Recipe> _results = [];
  bool _isLoading = false;
  String? _error;
  SearchType _searchType = SearchType.porNome;

  Future<void> _performSearch() async {
    if (_searchController.text.isEmpty) {
      setState(() {
        _results = [];
        _error = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token == null) {
        throw Exception('Usuário não autenticado.');
      }

      List<Recipe> recipes;
      if (_searchType == SearchType.porNome) {
        recipes = await _recipeService.searchRecipes(
          token: token,
          name: _searchController.text,
        );
      } else {
        recipes = await _recipeService.searchRecipes(
          token: token,
          authorId: _searchController.text,
        );
      }

      setState(() {
        _results = recipes;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _results = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos um Scaffold aqui para que a AppBar não seja duplicada
      // quando esta tela for usada dentro da HomeScreen.
      // O `appBar` da HomeScreen será o principal.
      // Se quiser testar esta tela individualmente, adicione um AppBar aqui.
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildSearchControls(),
          Expanded(child: _buildResultsList()),
        ],
      ),
    );
  }

  Widget _buildSearchControls() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          // Campo de busca
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: _searchType == SearchType.porNome
                  ? 'Buscar por nome da receita...'
                  : 'Buscar por ID do autor...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: _performSearch,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
            ),
            onSubmitted: (_) => _performSearch(),
          ),
          const SizedBox(height: 16),
          // Seletor de tipo de busca
          SegmentedButton<SearchType>(
            segments: const [
              ButtonSegment(
                value: SearchType.porNome,
                label: Text('Por Nome'),
                icon: Icon(Icons.fastfood),
              ),
              ButtonSegment(
                value: SearchType.porAutor,
                label: Text('Por Autor'),
                icon: Icon(Icons.person),
              ),
            ],
            selected: {_searchType},
            onSelectionChanged: (Set<SearchType> newSelection) {
              setState(() {
                _searchType = newSelection.first;
                _searchController.clear();
                _results = [];
                _error = null;
              });
            },
            style: SegmentedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryColor,
              selectedForegroundColor: Colors.white,
              selectedBackgroundColor: AppTheme.accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Erro: $_error',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_results.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma receita encontrada.\nFaça uma busca!',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Lista de resultados
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: ListView.builder(
        itemCount: _results.length,
        itemBuilder: (context, index) {
          final recipe = _results[index];
          return RecipeListItem(recipe: recipe);
        },
      )
    );
  }
}