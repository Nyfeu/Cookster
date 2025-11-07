import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:front_mobile/models/ingredient.dart';
import 'package:front_mobile/services/auth_service.dart';

class PantryService {
  static const String _apiGatewayUrl = "http://localhost:2000";

  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken(); 
    
    if (token == null) {
      return {
        'Content-Type': 'application/json; charset=UTF-8',
      };
    }
    
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }
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