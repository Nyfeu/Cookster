import 'dart:convert';                      // Para codificação/decodificação JSON 
import 'package:http/http.dart' as http;    // Para requisições HTTP
import '../models/recipe_model.dart';       // Modelo de Receita

class RecipeService {

  // URL base do serviço de receitas

  final String _baseUrl = 'http://localhost:2000/recipe';

  // Busca uma receita específica pelo ID
  // Utiliza token de autenticação para rotas protegidas
  // Lança exceção em caso de falha na requisição - tratada na camada superior

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

  // Busca receitas por nome ou autor
  // Utiliza token de autenticação para rotas protegidas
  // Lança exceção em caso de falha na requisição - tratada na camada superior

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

    final uri = Uri.parse('$_baseUrl/recipes').replace(queryParameters: queryParams);

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

  // Busca receitas sugeridas com base nos ingredientes da despensa do usuário
  // Utiliza token de autenticação para rotas protegidas
  // Lança exceção em caso de falha na requisição - tratada na camada superior

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