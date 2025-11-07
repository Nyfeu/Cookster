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
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    // --- CORREÇÃO ADICIONADA AQUI ---
    // Garante que o contexto esteja disponível antes de chamar o provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Dispara a busca inicial pelos ingredientes da despensa
      // Usamos context.read (ou listen: false) dentro do initState
      context.read<PantryProvider>().fetchIngredientes().catchError((e) {
        // Opcional: Tratar erro do fetch inicial, se necessário
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
    // --- FIM DA CORREÇÃO ---
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
            _isSearching = false;
          });
        }
        return;
      }

      if (mounted)
        setState(() {
          _isSearching = true;
        });
      try {
        final results = await _pantryService.getSuggestions(termo);
        if (mounted) {
          setState(() {
            _sugestoes = results;
            _isSearching = false;
          });
        }
      } catch (e) {
        if (mounted)
          setState(() {
            _isSearching = false;
          });
        debugPrint("Erro ao buscar sugestões: $e");
      }
    });
  }

  Future<void> _adicionarIngrediente(Ingrediente ingrediente) async {
    // Chama o provider para adicionar
    // O provider (espera-se) já chama fetchIngredientes após adicionar
    await context.read<PantryProvider>().adicionarIngrediente(ingrediente);

    // Limpa a busca
    _searchController.clear();
    if (mounted) {
      setState(() {
        _sugestoes = [];
      });
    }
  }

  Future<void> _removerIngrediente(Ingrediente ingrediente) async {
    // Confirmação
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
      // Chama o provider para remover
      // O provider (espera-se) já chama fetchIngredientes após remover
      await context.read<PantryProvider>().removerIngrediente(ingrediente);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Importamos o AppTheme se ainda não estiver (já estava)
    // import 'package:front_mobile/theme/app_theme.dart';

    return Scaffold(
      // A HomeScreen já fornece um AppBar
      body: Column(
        // 1. Removemos o Padding que estava aqui
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 2. Adicionamos o Container em volta do TextField
          Container(
            padding: const EdgeInsets.all(16.0), // Padding que estava no body
            decoration: BoxDecoration(
              // Cor de fundo bege claro da search_screen
              color: AppTheme.primaryColor.withOpacity(0.05),
              // Borda inferior da search_screen
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

          // 3. Adicionamos Padding horizontal às sugestões
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildSugestoesList(),
          ),

          const SizedBox(height: 16),

          // 4. Adicionamos Padding horizontal à lista da despensa
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
        // Mostra o loading APENAS se a lista estiver vazia
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

        // 🧺 --- ESTILO QUANDO A DESPENSA ESTÁ VAZIA ---
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

        // --- DESPENSA COM ITENS ---
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
                    // Título da Categoria
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

  /// Retorna um ícone baseado no nome da categoria.
  Icon _getIconePorCategoria(String categoria) {
    IconData iconeData;
    // Usa a mesma cor do texto do título
    final Color corIcone = AppTheme.primaryColor;

    // Normaliza o nome da categoria para a verificação
    String categoriaNorm = categoria.toLowerCase();

    // Mapeia o nome da categoria para um IconData
    switch (categoriaNorm) {
      // --- GRUPO: CARNES E PESCADOS ---
      case 'carnes':
      case 'carnes processadas':
        iconeData = Icons.kebab_dining_outlined;
        break;
      case 'pescados':
        iconeData = Icons.set_meal_outlined; // Ícone de peixe
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
      case 'folhas e ervas': // Agrupado com Legumes
      case 'ervas': // Agrupado com Legumes
        iconeData = Icons.grass_outlined;
        break;

      // --- GRUPO: PADARIA, GRÃOS E MASSAS ---
      case 'pães':
        iconeData = Icons.bakery_dining_outlined;
        break;
      case 'farinhas e fermentos':
      case 'fermentos':
        iconeData = Icons.grain_outlined; // Ícone de grão/pó
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
        iconeData = Icons.water_drop_outlined; // Ícone de gota (óleo)
        break;
      case 'molhos e pastas':
        iconeData = Icons.opacity_outlined; // Ícone de jarra
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
        iconeData = Icons.takeout_dining_outlined; // Ícone de pacote
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
        iconeData = Icons.eco_outlined; // Ícone de folha/noz
        break;

      // --- GRUPO: INDUSTRIALIZADOS E OUTROS ---
      case 'conservas':
        iconeData = Icons.inventory_2_outlined; // Ícone de enlatado/jarra
        break;
      case 'salgados': // Snacks
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

    // Retorna o Widget de Ícone
    return Icon(iconeData, color: corIcone, size: 20); // Tamanho do ícone
  }
}
