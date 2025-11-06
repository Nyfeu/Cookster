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
                backgroundColor: Colors.red),
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

      if (mounted) setState(() { _isSearching = true; });
      try {
        final results = await _pantryService.getSuggestions(termo);
        if (mounted) {
          setState(() {
            _sugestoes = results;
            _isSearching = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() { _isSearching = false; });
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
      builder: (ctx) => AlertDialog(
        title: const Text('Remover Ingrediente'),
        content: Text('Tem certeza que deseja remover ${ingrediente.nome}?'),
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
    return Scaffold(
      // A HomeScreen já fornece um AppBar
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Barra de Pesquisa
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar ingrediente...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12.0), // Ajuste no padding
                        child: SizedBox( // Tamanho definido
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),

            // 2. Lista de Sugestões
            _buildSugestoesList(),

            const SizedBox(height: 16),

            // 3. Lista da Despensa
            Expanded(
              child: _buildPantryList(),
            ),
          ],
        ),
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
              leading:
                  const Icon(Icons.add_circle_outline, color: AppTheme.accentColor),
              title: Text(sug.nome),
              subtitle:
                  Text(sug.categoria, style: const TextStyle(color: Colors.grey)),
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
              child:
                  Text(provider.error, style: const TextStyle(color: Colors.red)));
        }

        if (provider.ingredientes.isEmpty) {
          return const Center(child: Text('Sua despensa está vazia.'));
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
                    // Título da Categoria
                    Text(
                      categoria.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                        fontSize: 16,
                      ),
                    ),
                    const Divider(),
                    // Itens da Categoria
                    ...items.map((item) {
                      return ListTile(
                        title: Text(item.nome),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              color: Colors.redAccent),
                          onPressed: () => _removerIngrediente(item),
                        ),
                        onTap: () => _removerIngrediente(item), // Permite clicar no item todo
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
}