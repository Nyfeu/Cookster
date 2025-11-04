// lib/services/recipe_service.dart
import 'package:http/http.dart' as http;
import '../../models/recipe_model.dart';

class RecipeService {
  Future<Recipe> fetchRecipe(String idReceita, String token) async {
    if (idReceita.isEmpty) {
      throw Exception("ID da receita não encontrado.");
    }

    final url = Uri.parse('http://localhost:2000/recipe/recipes/$idReceita');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Usa o modelo para decodificar o JSON
        return recipeFromJson(response.body);
      } else {
        // Lança um erro que o FutureBuilder vai pegar
        throw Exception('Erro HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar receita: $e');
    }
  }
}