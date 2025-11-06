// lib/services/recipe_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/recipe_model.dart';

class RecipeService {
  // URL base apontando para o API Gateway
  final String _baseUrl = 'http://localhost:2000/recipe';

  Future<Recipe> fetchRecipe(String idReceita, String token) async {
    if (idReceita.isEmpty) {
      throw Exception("ID da receita não encontrado.");
    }

    // URL corrigida para usar o _baseUrl
    final url = Uri.parse('$_baseUrl/recipes/$idReceita');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return recipeFromJson(response.body);
      } else {
        throw Exception('Erro HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar receita: $e');
    }
  }

  // --- NOVO MÉTODO PARA BUSCA ---
  Future<List<Recipe>> searchRecipes({
    required String token,
    String? name,
    String? authorId,
  }) async {
    final queryParams = <String, String>{};
    if (name != null && name.isNotEmpty) {
      queryParams['name'] = name;
    }
    if (authorId != null && authorId.isNotEmpty) {
      // O backend espera 'user_id' para o autor
      queryParams['user_id'] = authorId;
    }

    // Constrói a URI com os parâmetros
    final uri =
        Uri.parse('$_baseUrl/recipes').replace(queryParameters: queryParams);

    print('[RecipeService] Buscando receitas em: $uri');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // A API retorna uma LISTA de receitas
        final List<dynamic> body = json.decode(response.body);
        
        // Mapeia a lista de JSON para uma lista de Objetos Recipe
        return body.map((dynamic item) => Recipe.fromJson(item)).toList();
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(
            errorBody['error'] ?? 'Falha ao buscar receitas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na conexão durante a busca: $e');
    }
  }
}