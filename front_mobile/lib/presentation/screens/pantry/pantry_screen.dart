import 'dart:async';                                                             // Usado para Timer
import 'package:flutter/material.dart';                                          // Padrão do Flutter
import 'package:front_mobile/data/models/ingredient.dart';                       // Modelo de Ingrediente
import 'package:front_mobile/presentation/providers/pantry_provider.dart';       // Provider de Despensa
import 'package:front_mobile/data/services/pantry_service.dart';                 // Serviço de Despensa
import 'package:front_mobile/core/theme/app_theme.dart';                         // Tema da Aplicação
import 'package:provider/provider.dart';                                         // Provider para gerenciamento de estado

// Tela de Despensa do Usuário 
// Permite buscar, adicionar e remover ingredientes da despensa
// Utiliza PantryProvider para gerenciar o estado da despensa
// e PantryService para buscar sugestões de ingredientes.

class PantryScreen extends StatefulWidget {

  // Rota nomeada para navegação
  static const String routeName = '/pantry';

  const PantryScreen({super.key});

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {

  // Controlador para o campo de busca, serve para capturar o texto digitado
  // e reagir a mudanças para buscar sugestões de ingredientes
  
  final TextEditingController _searchController = TextEditingController();

  // Serviço para buscar sugestões de ingredientes da API (api-gateway -> mss-ingredient-classifier)

  final PantryService _pantryService = PantryService();

  // Lista de sugestões de ingredientes baseada no texto digitado

  List<Ingrediente> _sugestoes = [];

  // Timer para debounce da requisição de sugestão de ingredientes

  Timer? _debounce;

  // Estado inicial

  @override
  void initState() {
    super.initState();

    // Executa a callback function quando o campo de busca muda
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

  // Remove listener e timer

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Verificações para realizar a pesquisa de ingrediente

  void _onSearchChanged() {

    // Realiza o debounce da digitação na barra de pesquisa

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final termo = _searchController.text;
    
      // Se tiver menos que duas letras - não realiza requisição
      // Configura uma lista vazia
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

  // Utiliza o PantryProvider para adicionar ingredientes da despensa do usuário

  Future<void> _adicionarIngrediente(Ingrediente ingrediente) async {

    await context.read<PantryProvider>().adicionarIngrediente(ingrediente);

    _searchController.clear();
    if (mounted) {
      setState(() {
        _sugestoes = [];
      });
    }

  }

  // Utiliza o PantryProvider para remover ingredientes da despensa do usuário

  Future<void> _removerIngrediente(Ingrediente ingrediente) async {

    // Mostra um diálogo para confirmar a remoção do ingrediente da despensa
    // Conforme: https://api.flutter.dev/flutter/material/AlertDialog-class.html

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

    // Caso o usuário selecione 'Remover' (confirme), o PantryProvider
    // é utilizado para remover o ingrediente (comunicando-se com o serviço
    // na camada subjacente).

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

  //  Constrói a lista da despensa exibida na tela.

  Widget _buildPantryList() {

    // Exibe estados diferentes conforme o estado do PantryProvider:
    // - Indicador de carregamento quando isLoading é true e não há ingredientes.
    // - Mensagem de erro quando provider.error não está vazia.
    // - Tela informando que a despensa está vazia quando não há ingredientes.
    // - Lista agrupada por categorias com RefreshIndicator para atualizar e ações para remover itens.

    // IMPORTANTE: O uso de Consumer<PantryProvider> permite que apenas este subtree seja reconstruído
    // quando o PantryProvider emitir mudanças (por exemplo carregamento, erro, atualização
    // ou remoção de ingredientes), evitando rebuilds desnecessários dos widgets-pais.

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

        // Componente para indicar o refresh da página
        // Vide: https://api.flutter.dev/flutter/material/RefreshIndicator-class.html

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

  // Método auxiliar para obtenção do ícone por categoria
  // Utiliza 'Icons' para cada categoria - conforme material de aula

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
