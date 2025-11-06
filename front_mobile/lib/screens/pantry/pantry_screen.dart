import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:front_mobile/models/ingredient.dart'; // Importe o modelo
import 'package:front_mobile/providers/pantry_provider.dart';
import 'package:front_mobile/providers/auth_provider.dart'; // Importe o provider // Você precisará do package 'provider'
// import 'package:shared_preferences/shared_preferences.dart'; // Para buscar o token

// --- A Tela da Despensa (PantryScreen) ---
class PantryScreen extends StatefulWidget {
  static const String routeName = '/pantry';
  const PantryScreen({Key? key}) : super(key: key);

  @override
  _PantryScreenState createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Ingrediente> _sugestoes = [];
  bool _isLoadingSugestoes = false;
  
  // Debouncer simples para evitar chamadas de API em cada tecla
  Future<void> _onSearchChanged(String searchTerm) async {
    if (searchTerm.trim().length < 2) {
      setState(() {
        _sugestoes = [];
      });
      return;
    }

    setState(() {
      _isLoadingSugestoes = true;
    });

    // Simulação de como o token seria pego
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // final token = prefs.getString("token");
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) {
       print("Token não encontrado");
       setState(() { _isLoadingSugestoes = false; });
       return;
    }

    try {
      final res = await http.get(
        Uri.parse("http://localhost:2000/ingredient/sugestoes?termo=${Uri.encodeComponent(searchTerm)}"),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final List<dynamic> sugestoesData = data['sugestoes'] ?? [];
        setState(() {
          _sugestoes = sugestoesData.map((item) => Ingrediente.fromJson(item)).toList();
        });
      } else {
        print("Erro ao buscar sugestões: ${res.body}");
        setState(() { _sugestoes = []; });
      }
    } catch (err) {
      print("Erro de rede ao buscar sugestões: $err");
      setState(() { _sugestoes = []; });
    } finally {
      setState(() {
        _isLoadingSugestoes = false;
      });
    }
  }

  void _adicionarIngrediente(Ingrediente ingrediente) {
    // Chama o provider para adicionar
    Provider.of<PantryProvider>(context, listen: false).adicionarIngrediente(ingrediente);
    
    // Limpa a busca
    _searchController.clear();
    setState(() {
      _sugestoes = [];
    });
  }

  @override
  void initState() {
    super.initState();
    // Carrega os ingredientes da despensa ao iniciar a tela
    // O provider cuida de não carregar se já tiver os dados
    Provider.of<PantryProvider>(context, listen: false).fetchIngredientes();
  }

  @override
  Widget build(BuildContext context) {
    // Consome o provider para obter a lista de ingredientes
    final pantryProvider = context.watch<PantryProvider>();

    return Scaffold(
      // A AppBar substitui o título <h4> e o botão de fechar "×"
      appBar: AppBar(
        title: Text("Sua Despensa"),
        backgroundColor: Colors.white, // Adapte às suas cores
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white, // var(--background-color)
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0), // (from .side-panel { padding: 1rem; })
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchSection(),
            if (_sugestoes.isNotEmpty) _buildSuggestionsList(),
            const SizedBox(height: 16),
            _buildPantryList(pantryProvider),
          ],
        ),
      ),
    );
  }

  // Constrói a barra de pesquisa
  Widget _buildSearchSection() {
    // (from .search-wrapper and .search-bar)
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // var(--background-color)
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8.0,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: "Buscar ingrediente...",
          // (from .search-icon)
          prefixIcon: Icon(Icons.search, color: Color(0xFF595C5F), size: 20),
          // (from .search-bar)
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide.none, // border-color: transparent;
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 10.0),
        ),
      ),
    );
  }

  // Constrói a lista de sugestões
  Widget _buildSuggestionsList() {
    // (from .dropdown-menu)
    return Card(
      elevation: 4.0, // (from shadow)
      margin: const EdgeInsets.only(top: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: _sugestoes.map((item) {
          // (from .dropdown-item)
          return ListTile(
            leading: Icon(Icons.add, size: 18), // (from .pi-plus me-2)
            title: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 14, color: Colors.black),
                children: [
                  TextSpan(text: "${item.nome} "),
                  TextSpan(
                    text: "(${item.categoria})",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            dense: true,
            onTap: () => _adicionarIngrediente(item),
            // (from .dropdown-item:hover)
            hoverColor: Colors.grey[200], // var(--transition-color)
          );
        }).toList(),
      ),
    );
  }

  // Constrói a lista de ingredientes da despensa
  Widget _buildPantryList(PantryProvider pantryProvider) {
    if (pantryProvider.isLoading && pantryProvider.ingredientes.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    final categorias = pantryProvider.categoriasOrdenadas;
    
    return ListView.builder(
      itemCount: categorias.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final categoria = categorias[index];
        final items = pantryProvider.agrupadoPorCategoria[categoria]!;
        final bool comLinha = index != 0; // (from .com-linha)

        // (from .categoria-section)
        return Container(
          margin: const EdgeInsets.only(top: 16.0),
          padding: EdgeInsets.only(top: comLinha ? 8.0 : 0),
          decoration: BoxDecoration(
            border: comLinha
                ? Border(
                    top: BorderSide(
                      color: Color(0xFFF07A3B), // var(--primary-color)
                      width: 1.0,
                    ),
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // (from .categoria-section h6)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 24, 8, 0),
                child: Text(
                  categoria.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14, // 0.85rem
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.02,
                  ),
                ),
              ),
              // (from ul.list-unstyled)
              Wrap(
                spacing: 4.0, // (from margin: 4px)
                runSpacing: 4.0,
                children: items.map((item) {
                  // (from .ingredient-item)
                  return GestureDetector(
                    onTap: () => pantryProvider.removerIngrediente(item),
                    child: Chip(
                      label: Text(
                        item.nome,
                        style: TextStyle(fontSize: 12), // 0.7rem
                      ),
                      backgroundColor: Color(0xFFE0E0E0),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: StadiumBorder(), // (from border-radius: 20px)
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}