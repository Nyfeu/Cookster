import 'dart:async';
import 'package:flutter/material.dart';
import 'package:front_mobile/models/ingredient.dart';
import 'package:front_mobile/providers/pantry_provider.dart';
import 'package:front_mobile/services/pantry_service.dart';
import 'package:front_mobile/theme/app_theme.dart';
import 'package:provider/provider.dart';

class PantryScreen extends StatefulWidget {
  static const String routeName = '/pantry';

  const PantryScreen({super.key});

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PantryService _pantryService = PantryService();
  List<Ingrediente> _sugestoes = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PantryProvider>().fetchIngredientes().catchError((e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao carregar despensa inicial: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final termo = _searchController.text;
      if (termo.length < 2) {
        if (mounted) {
          setState(() {
            _sugestoes = [];
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
        });
      }
      try {
        final results = await _pantryService.getSuggestions(termo);
        if (mounted) {
          setState(() {
            _sugestoes = results;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
          });
        }
        debugPrint("Erro ao buscar sugestões: $e");
      }
    });
  }

  Future<void> _adicionarIngrediente(Ingrediente ingrediente) async {

    await context.read<PantryProvider>().adicionarIngrediente(ingrediente);

    _searchController.clear();
    if (mounted) {
      setState(() {
        _sugestoes = [];
      });
    }

  }

  Future<void> _removerIngrediente(Ingrediente ingrediente) async {

    final bool? confirmar = await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Remover Ingrediente'),
            content: Text(
              'Tem certeza que deseja remover ${ingrediente.nome}?',
            ),
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.of(ctx).pop(false),
              ),
              TextButton(
                child: const Text('Remover'),
                onPressed: () => Navigator.of(ctx).pop(true),
              ),
            ],
          ),
    );

    if (confirmar == true) {
      await context.read<PantryProvider>().removerIngrediente(ingrediente);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0), 
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar ingredientes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {},
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
              ),
              onSubmitted: (_) {},
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildSugestoesList(),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildPantryList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSugestoesList() {
    if (_sugestoes.isEmpty) return const SizedBox.shrink();

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.25,
      ),
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.only(top: 8),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _sugestoes.length,
          itemBuilder: (context, index) {
            final sug = _sugestoes[index];
            return ListTile(
              leading: const Icon(
                Icons.add_circle_outline,
                color: AppTheme.accentColor,
              ),
              title: Text(sug.nome),
              subtitle: Text(
                sug.categoria,
                style: const TextStyle(color: Colors.grey),
              ),
              onTap: () => _adicionarIngrediente(sug),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPantryList() {
    return Consumer<PantryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.ingredientes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/log.png', height: 160),
                  const SizedBox(height: 24),
                  Text(
                    "Erro ao carregar a despensa",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error,
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

        if (provider.ingredientes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/despensa.png', height: 300),
                  const SizedBox(height: 24),
                  Text(
                    "Sua despensa está vazia",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Adicione ingredientes para começar a montar suas receitas!",
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

        final categorias = provider.categoriasOrdenadas;

        return RefreshIndicator(
          onRefresh: () => provider.fetchIngredientes(),
          child: ListView.builder(
            itemCount: categorias.length,
            itemBuilder: (context, index) {
              final categoria = categorias[index];
              final items = provider.agrupadoPorCategoria[categoria]!;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _getIconePorCategoria(categoria),
                        const SizedBox(width: 8),
                        Text(
                          categoria.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    ...items.map((item) {
                      return ListTile(
                        title: Text(item.nome),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => _removerIngrediente(item),
                        ),
                        onTap: () => _removerIngrediente(item),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Icon _getIconePorCategoria(String categoria) {
    IconData iconeData;
    final Color corIcone = AppTheme.primaryColor;

    String categoriaNorm = categoria.toLowerCase();

    switch (categoriaNorm) {
      // --- GRUPO: CARNES E PESCADOS ---
      case 'carnes':
      case 'carnes processadas':
        iconeData = Icons.kebab_dining_outlined;
        break;
      case 'pescados':
        iconeData = Icons.set_meal_outlined;
        break;

      // --- GRUPO: LATICÍNIOS E OVOS ---
      case 'laticínios':
      case 'laticínios (alternativas)':
        iconeData = Icons.icecream_outlined;
        break;
      case 'ovos e derivados':
        iconeData = Icons.egg_outlined;
        break;

      // --- GRUPO: FRUTAS, LEGUMES E ERVAS ---
      case 'frutas':
        iconeData = Icons.apple_outlined;
        break;
      case 'legumes':
      case 'folhas e ervas': 
      case 'ervas': 
        iconeData = Icons.grass_outlined;
        break;

      // --- GRUPO: PADARIA, GRÃOS E MASSAS ---
      case 'pães':
        iconeData = Icons.bakery_dining_outlined;
        break;
      case 'farinhas e fermentos':
      case 'fermentos':
        iconeData = Icons.grain_outlined;
        break;
      case 'grãos':
        iconeData = Icons.rice_bowl_outlined;
        break;
      case 'massas':
        iconeData = Icons.ramen_dining_outlined;
        break;

      // --- GRUPO: TEMPEROS, MOLHOS E ÓLEOS ---
      case 'especiarias':
      case 'temperos':
        iconeData = Icons.filter_vintage_outlined;
        break;
      case 'óleos e gorduras':
        iconeData = Icons.water_drop_outlined; 
        break;
      case 'molhos e pastas':
        iconeData = Icons.opacity_outlined; 
        break;
      case 'aromatizantes':
        iconeData = Icons.flare_outlined;
        break;

      // --- GRUPO: BEBIDAS ---
      case 'bebidas':
        iconeData = Icons.local_bar_outlined;
        break;
      case 'bebidas alcoólicas':
        iconeData = Icons.sports_bar_outlined;
        break;

      // --- GRUPO: DOCES E SOBREMESAS ---
      case 'açúcares e adoçantes':
        iconeData = Icons.takeout_dining_outlined; 
        break;
      case 'doces':
        iconeData = Icons.cookie_outlined;
        break;
      case 'sobremesas':
        iconeData = Icons.cake_outlined;
        break;

      // --- GRUPO: NOZES E SEMENTES ---
      case 'oleaginosas':
      case 'sementes':
        iconeData = Icons.eco_outlined; 
        break;

      // --- GRUPO: INDUSTRIALIZADOS E OUTROS ---
      case 'conservas':
        iconeData = Icons.inventory_2_outlined; 
        break;
      case 'salgados': 
        iconeData = Icons.fastfood_outlined;
        break;
      case 'aditivos':
        iconeData = Icons.science_outlined;
        break;

      // --- ÍCONE PADRÃO ---
      default:
        // Ícone padrão para categorias não mapeadas
        iconeData = Icons.label_outline;
    }

    return Icon(iconeData, color: corIcone, size: 20); 
    
  }
}
