import 'package:flutter/material.dart';
import 'package:front_mobile/models/ingredient.dart';
import 'package:front_mobile/services/pantry_service.dart';
import 'dart:collection';

class PantryProvider with ChangeNotifier {
  final PantryService _pantryService = PantryService();

  List<Ingrediente> _ingredientes = [];
  bool _isLoading = false;
  String _error = '';

  List<Ingrediente> get ingredientes => _ingredientes;
  bool get isLoading => _isLoading;
  String get error => _error;

  Map<String, List<Ingrediente>> get agrupadoPorCategoria {
    final map = <String, List<Ingrediente>>{};
    for (var item in _ingredientes) {
      final cat = item.categoria;
      if (!map.containsKey(cat)) {
        map[cat] = [];
      }
      map[cat]!.add(item);
    }
    
    map.forEach((categoria, lista) {
      lista.sort((a, b) => a.nome.compareTo(b.nome));
    });
    
    return map;
  }

  List<String> get categoriasOrdenadas {
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
      _ingredientes = await _pantryService.addIngredient(ingrediente);
    } catch (e) {
      _error = "Falha ao adicionar ingrediente: $e";
      await fetchIngredientes(); 
    }
    notifyListeners();
  }

  Future<void> removerIngrediente(Ingrediente ingrediente) async {
    _error = '';
    
    final int index = _ingredientes.indexOf(ingrediente);
    if (index == -1) return;
    
    _ingredientes.removeAt(index);
    notifyListeners();

    try {
      await _pantryService.removeIngredient(ingrediente);
    } catch (e) {
      _error = "Falha ao remover ingrediente: $e";
      _ingredientes.insert(index, ingrediente);
      notifyListeners();
    }
  }
}