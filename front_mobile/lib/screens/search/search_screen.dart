import 'package:flutter/material.dart';
import 'package:front_mobile/models/recipe_model.dart';
import 'package:front_mobile/models/user_profile.dart';
import 'package:front_mobile/providers/auth_provider.dart';
import 'package:front_mobile/services/profile_service.dart';
import 'package:front_mobile/services/recipe_service.dart';
import 'package:front_mobile/theme/app_theme.dart';
import 'package:front_mobile/widgets/search/recipe_list_item.dart';
import 'package:provider/provider.dart';

enum SearchType { porNome, porAutor, porUsuario }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _recipeService = RecipeService();
  final _profileService = ProfileService();

  List<dynamic> _results = [];
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

      List<dynamic> searchData;

      if (_searchType == SearchType.porNome) {
        searchData = await _recipeService.searchRecipes(
          token: token,
          name: _searchController.text,
        );
      } else if (_searchType == SearchType.porAutor) {
        searchData = await _recipeService.searchRecipes(
          token: token,
          authorId: _searchController.text,
        );
      } else {
        searchData = await _profileService.searchProfiles(
          token: token,
          name: _searchController.text,
        );
      }

      setState(() {
        _results = searchData;
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
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText:
                  _searchType == SearchType.porNome
                      ? 'Buscar por nome da receita...'
                      : _searchType == SearchType.porAutor
                      ? 'Buscar receita por autor...'
                      : 'Buscar usuário por nome...',
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
            // SEGMENTOS ATUALIZADOS
            segments: const [
              ButtonSegment(
                value: SearchType.porNome,
                label: Text('Receitas'),
                icon: Icon(Icons.fastfood),
              ),
              ButtonSegment(
                value: SearchType.porAutor,
                label: Text('Por Autor'),
                icon: Icon(Icons.person_search),
              ),
              ButtonSegment(
                value: SearchType.porUsuario,
                label: Text('Usuários'),
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

  Widget _buildUserListItem(UserProfile user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[200],
        child: const Icon(Icons.person_outline, color: Colors.grey),
      ),
      title: Text(user.name),
      subtitle: Text(user.bio, maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: () {
        /*
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(userId: user.userId), // Exemplo
          ),
        );
        */
      },
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
      String emptyMessage;
      if (_searchType == SearchType.porUsuario) {
        emptyMessage = 'Nenhum usuário encontrado.';
      } else {
        emptyMessage = 'Nenhuma receita encontrada.';
      }

      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/reg.png', height: 200),
              const SizedBox(height: 24),
              Text(
                emptyMessage,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Faça uma busca!",
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    // Lista de resultados
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: ListView.builder(
        itemCount: _results.length,
        itemBuilder: (context, index) {
          final item = _results[index];

          if (_searchType == SearchType.porUsuario) {
            if (item is UserProfile) {
              return _buildUserListItem(item);
            }
          } else {
            if (item is Recipe) {
              return RecipeListItem(recipe: item);
            }
          }

          // Fallback caso o tipo não corresponda (não deve acontecer)
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
