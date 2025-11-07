import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe_model.dart';

class RecipeService {
  final String _baseUrl = 'http://localhost:2000/recipe';

  Future<Recipe> fetchRecipe(String idReceita, String token) async {
    if (idReceita.isEmpty) {
      throw Exception("ID da receita não encontrado.");
    }

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
      queryParams['user_id'] = authorId;
    }

    final uri =
        Uri.parse('$_baseUrl/recipes').replace(queryParameters: queryParams);



    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = json.decode(response.body);
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

  Future<List<Recipe>> fetchSuggestedRecipes({
    required String token,
  }) async {
    final uri = Uri.parse('$_baseUrl/suggest');



    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = json.decode(response.body);
        return body.map((dynamic item) => Recipe.fromJson(item)).toList();
      }

      if (response.statusCode == 400 || response.statusCode == 404) {
        final decoded = json.decode(response.body);
        final message = decoded['error'] ?? decoded['message'] ?? '';

        if (message.toString().contains('Nenhum ingrediente') ||
            message.toString().contains('vazia')) {
          return []; 
        }
      }

      throw Exception(
        'Falha ao buscar sugestões: ${response.statusCode} - ${response.reasonPhrase}',
      );
    } catch (e) {
      throw Exception('Erro na conexão ao buscar sugestões: $e');
    }
  }
    
}