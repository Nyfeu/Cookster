// lib/providers/pantry_provider.dart

import 'package:flutter/material.dart';
import 'package:front_mobile/models/ingredient.dart';
import 'package:front_mobile/services/pantry_service.dart';
import 'dart:collection'; // Para o SplayTreeMap

class PantryProvider with ChangeNotifier {
  final PantryService _pantryService = PantryService();

  List<Ingrediente> _ingredientes = [];
  bool _isLoading = false;
  String _error = '';

  List<Ingrediente> get ingredientes => _ingredientes;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Getter para agrupar ingredientes, similar ao React
  Map<String, List<Ingrediente>> get agrupadoPorCategoria {
    final map = <String, List<Ingrediente>>{};
    for (var item in _ingredientes) {
      final cat = item.categoria;
      if (!map.containsKey(cat)) {
        map[cat] = [];
      }
      map[cat]!.add(item);
    }
    
    // Ordena os itens dentro de cada categoria
    map.forEach((categoria, lista) {
      lista.sort((a, b) => a.nome.compareTo(b.nome));
    });
    
    return map;
  }

  // Getter para ordenar as categorias, similar ao React
  List<String> get categoriasOrdenadas {
    // Usamos SplayTreeMap para ordenar as chaves (categorias) automaticamente
    // e depois movemos "Outros" para o final.
    final sortedMap = SplayTreeMap<String, List<Ingrediente>>.from(
      agrupadoPorCategoria,
      (a, b) => a.compareTo(b),
    );

    final keys = sortedMap.keys.toList();
    if (keys.contains("Outros")) {
      keys.remove("Outros");
      keys.add("Outros");
    }
    return keys;
  }

  Future<void> fetchIngredientes() async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    try {
      _ingredientes = await _pantryService.getPantryIngredients();
    } catch (e) {
      _error = "Falha ao carregar despensa: $e";
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> adicionarIngrediente(Ingrediente ingrediente) async {
    _error = '';
    try {
      // O backend retorna a lista atualizada
      _ingredientes = await _pantryService.addIngredient(ingrediente);
    } catch (e) {
      _error = "Falha ao adicionar ingrediente: $e";
      // Se falhar, recarregamos a lista original para garantir consistência
      await fetchIngredientes(); 
    }
    notifyListeners(); // Notifica a FeedScreen e a PantryScreen
  }

  Future<void> removerIngrediente(Ingrediente ingrediente) async {
    _error = '';
    
    // Remosão otimista (atualiza a UI primeiro)
    final int index = _ingredientes.indexOf(ingrediente);
    if (index == -1) return; // Não encontrou
    
    _ingredientes.removeAt(index);
    notifyListeners(); // Notifica a FeedScreen e a PantryScreen

    try {
      // Tenta remover no backend
      await _pantryService.removeIngredient(ingrediente);
    } catch (e) {
      _error = "Falha ao remover ingrediente: $e";
      // Se falhar, adiciona de volta na UI
      _ingredientes.insert(index, ingrediente);
      notifyListeners();
    }
  }
}