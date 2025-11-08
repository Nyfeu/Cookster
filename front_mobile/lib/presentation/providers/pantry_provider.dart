import 'package:flutter/material.dart';                                // Para ChangeNotifier padrão do Flutter
import 'package:front_mobile/data/models/ingredient.dart';             // Modelo de Ingrediente
import 'package:front_mobile/data/services/pantry_service.dart';       // Serviço de despensa

// PantryProvider gerencia o estado da despensa do usuário na aplicação.
// Utiliza ChangeNotifier para notificar listeners sobre mudanças de estado (adição, remoção
// de ingredientes etc.).
// Armazena a lista de ingredientes da despensa, além de fornecer métodos para buscar,
// adicionar e remover ingredientes.
// Camada de serviço (PantryService) é usada para interagir com a API de despensa e gerenciar o estado
// da camada de apresentação.

class PantryProvider with ChangeNotifier {

  // Instância do serviço de despensa

  final PantryService _pantryService = PantryService();

  // Dados da despensa

  List<Ingrediente> _ingredientes = [];
  bool _isLoading = false;
  String _error = '';

  // Getters para acessar os dados de despensa

  List<Ingrediente> get ingredientes => _ingredientes;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Método para agrupar ingredientes por categoria
  // Retorna um mapa onde a chave é a categoria e o valor é a lista de ingredientes daquela categoria
  // Ingredientes dentro de cada categoria são ordenados alfabeticamente

  Map<String, List<Ingrediente>> get agrupadoPorCategoria {

    // Agrupa ingredientes por categoria

    final map = <String, List<Ingrediente>>{};
    
    // Percorre todos os ingredientes e os adiciona ao mapa conforme a categoria

    for (var item in _ingredientes) {
      final cat = item.categoria;
      if (!map.containsKey(cat)) {
        map[cat] = [];
      }
      map[cat]!.add(item);
    }
    
    // Ordena os ingredientes dentro de cada categoria (alfabeticamente)

    map.forEach((categoria, lista) {
      lista.sort((a, b) => a.nome.compareTo(b.nome));
    });
    
    return map;
  
  }

  // Método para obter categorias ordenadas
  // Retorna uma lista de categorias ordenadas alfabeticamente
  // A categoria "Outros" sempre vem por último

  List<String> get categoriasOrdenadas {

    // Pega as chaves do mapa original (sem ordem)
    final keys = agrupadoPorCategoria.keys.toList();

    // Ordena a própria lista
    keys.sort(); 

    // Faz a mesma lógica para "Outros"
    if (keys.contains("Outros")) {
      keys.remove("Outros");
      keys.add("Outros");
    }

    return keys;

  }

  // Método para buscar ingredientes da despensa
  // Atualiza o estado de carregamento e notifica listeners
  // Em caso de erro, armazena a mensagem de erro

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

  // Método para adicionar um ingrediente à despensa
  // Em caso de erro, armazena a mensagem de erro e recarrega a
  // despensa para garantir consistência

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

  // Método para remover um ingrediente da despensa
  // Em caso de erro, armazena a mensagem de erro e re-insere o
  // ingrediente removido para garantir consistência

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