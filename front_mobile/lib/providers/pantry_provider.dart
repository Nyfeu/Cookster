import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:front_mobile/models/ingredient.dart';

class PantryProvider with ChangeNotifier {
  // --- 1. VARIÁVEIS PARA RECEBER DADOS ---
  String? _token;
  List<Ingrediente> _ingredientes = [];
  bool _isLoading = false;

  // --- 2. CONSTRUTOR ATUALIZADO ---
  // Este construtor permite que o main.dart injete o token e a lista anterior
  PantryProvider(this._token, this._ingredientes);

  // Getters
  List<Ingrediente> get ingredientes => _ingredientes;
  bool get isLoading => _isLoading;

  // Mapa agrupado (seu código original, está correto)
  Map<String, List<Ingrediente>> get agrupadoPorCategoria {
    final Map<String, List<Ingrediente>> acc = {};
    for (var item in _ingredientes) {
      final cat = item.categoria.isEmpty ? "Outros" : item.categoria;
      if (!acc.containsKey(cat)) {
        acc[cat] = [];
      }
      acc[cat]!.add(item);
    }
    acc.forEach((key, value) {
      value.sort((a, b) => a.nome.compareTo(b.nome));
    });
    return acc;
  }

  // Categorias ordenadas (seu código original, está correto)
  List<String> get categoriasOrdenadas {
    final keys = agrupadoPorCategoria.keys.toList();
    keys.sort((a, b) {
      if (a == "Outros") return 1;
      if (b == "Outros") return -1;
      return a.compareTo(b);
    });
    return keys;
  }

  // --- 3. (INCONGRUÊNCIA 1 CORRIGIDA) ---
  // Remove o placeholder e usa o token real
  Future<String?> _getToken() async {
    return _token;
  }

  // Esta função ainda precisa ser implementada (Incongruência 3)
  Future<void> fetchIngredientes() async {
    // (IMPLEMENTAÇÃO FUTURA: Fazer um GET para 'http://localhost:2000/pantry/ingredients'
    // usando o _getToken() e atualizar _ingredientes com a resposta)
    
    // Por enquanto, mantemos os dados de exemplo para a UI funcionar
    _isLoading = true;
    notifyListeners();
    _ingredientes = [
      Ingrediente(nome: "Farinha", categoria: "Grãos e Cereais"),
      Ingrediente(nome: "Ovos", categoria: "Laticínios e Ovos"),
      Ingrediente(nome: "Leite", categoria: "Laticínios e Ovos"),
      Ingrediente(nome: "Alho", categoria: "Legumes"),
    ];
    _isLoading = false;
    notifyListeners();
  }

  // As funções abaixo agora usarão o token correto
  Future<void> adicionarIngrediente(Ingrediente ingrediente) async {
    final token = await _getToken();
    if (token == null) {
      print("Não é possível adicionar: Token nulo.");
      return;
    }

    try {
      final res = await http.post(
        Uri.parse("http://localhost:2000/pantry/ingredients"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(ingrediente.toJson()),
      );

      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        _ingredientes = data.map((item) => Ingrediente.fromJson(item)).toList();
        notifyListeners();
      } else {
        print("Erro ao adicionar ingrediente: ${res.body}");
      }
    } catch (err) {
      print("Erro geral ao adicionar ingrediente: $err");
    }
  }

  Future<void> removerIngrediente(Ingrediente ingrediente) async {
    final token = await _getToken();
    if (token == null) {
      print("Não é possível remover: Token nulo.");
      return;
    }

    try {
      final res = await http.delete(
        Uri.parse("http://localhost:2000/pantry/ingredients"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(ingrediente.toJson()),
      );

      if (res.statusCode == 200) {
        _ingredientes.removeWhere((ing) => ing.nome == ingrediente.nome && ing.categoria == ingrediente.categoria);
        notifyListeners();
        print("Ingrediente '${ingrediente.nome}' removido com sucesso!");
      } else {
        print("Erro ao remover ingrediente: ${res.body}");
      }
    } catch (err) {
      print("Erro geral ao remover ingrediente: $err");
    }
  }
}