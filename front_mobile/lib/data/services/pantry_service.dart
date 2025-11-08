import 'dart:convert';                                            // Para codificação/decodificação JSON 
import 'package:http/http.dart' as http;                          // Para requisições HTTP
import 'package:front_mobile/data/models/ingredient.dart';        // Modelo de Ingrediente
import 'package:front_mobile/data/services/auth_service.dart';    // Serviço de autenticação para obter token

class PantryService {

  // URL base do API Gateway

  static const String _apiGatewayUrl = "http://localhost:2000";

  // Método auxiliar para obter 
  // cabeçalhos comuns com token de autenticação (ou sem)
  // para o API-GATEWAY

  static Future<Map<String, String>> _getHeaders() async {
    
    final token = await AuthService.getToken(); 
    
    // Caso não seja uma rota protegida, retorna apenas o cabeçalho padrão

    if (token == null) {
      return {
        'Content-Type': 'application/json; charset=UTF-8',
      };
    }

    // Caso haja token, inclui no cabeçalho para rotas protegidas
    
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };

  }

  // Busca os ingredientes da despensa do usuário autenticado
  // Lança exceção em caso de falha na requisição - ttratada na camada superior

  Future<List<Ingrediente>> getPantryIngredients() async {
    final uri = Uri.parse('$_apiGatewayUrl/pantry/ingredients');
    try {
      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((item) => Ingrediente.fromMap(item)).toList();
      } else {
        throw Exception("Falha ao carregar ingredientes");
      }
    } catch (e) {
      throw Exception("Erro de conexão: $e");
    }
  }

  // Adiciona um ingrediente à despensa do usuário autenticado
  // Retorna a lista atualizada de ingredientes
  // Lança exceção em caso de falha na requisição - tratada na camada superior

  Future<List<Ingrediente>> addIngredient(Ingrediente ingrediente) async {
    final uri = Uri.parse('$_apiGatewayUrl/pantry/ingredients');
    try {
      final headers = await _getHeaders();
      final body = ingrediente.toJson();
      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 201) {
        // O backend retorna a nova lista completa de ingredientes
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((item) => Ingrediente.fromMap(item)).toList();
      } else {
        throw Exception("Falha ao adicionar ingrediente");
      }
    } catch (e) {
      throw Exception("Erro de conexão: $e");
    }
  }

  // Remove um ingrediente da despensa do usuário autenticado
  // Lança exceção em caso de falha na requisição - tratada na camada superior

  Future<void> removeIngredient(Ingrediente ingrediente) async {
    final uri = Uri.parse('$_apiGatewayUrl/pantry/ingredients');
    try {
      final headers = await _getHeaders();
      final body = ingrediente.toJson();
      
      final request = http.Request('DELETE', uri)
        ..headers.addAll(headers)
        ..body = body;
        
      final response = await request.send();

      if (response.statusCode != 200) {
         throw Exception("Falha ao remover ingrediente");
      }
    } catch (e) {
      throw Exception("Erro de conexão: $e");
    }
  }

  // Busca sugestões de ingredientes com base em um termo parcial
  // Retorna uma lista de ingredientes sugeridos
  // Não lança exceção - em caso de falha, retorna lista vazia

  // Se comunica com o mss-ingredient-classifier via API-GATEWAY
  // que classifica o ingrediente via ChromaDB

  Future<List<Ingrediente>> getSuggestions(String termo) async {
    if (termo.trim().length < 2) return [];

    final uri = Uri.parse(
        '$_apiGatewayUrl/ingredient/sugestoes?termo=${Uri.encodeComponent(termo)}');
    try {
      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> sugestoesData = data['sugestoes'] ?? [];
        return sugestoesData.map((item) => Ingrediente.fromMap(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}