// lib/services/pantry_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:front_mobile/models/ingredient.dart';
import 'package:front_mobile/services/auth_service.dart'; // Assumindo que você tem este serviço para pegar o token

class PantryService {
  // Use 10.0.2.2 para localhost se estiver usando o emulador Android
  // Ou o IP da sua máquina na rede local se estiver usando um dispositivo físico
  static const String _apiGatewayUrl = "http://localhost:2000";

  // Helper para obter os headers com o token
  static Future<Map<String, String>> _getHeaders() async {
    // Você já deve ter um serviço de autenticação que salva o token
    // Usando SharedPreferences ou FlutterSecureStorage.
    // Aqui, assumo que AuthService.getToken() busca o token salvo.
    final token = await AuthService.getToken(); 
    
    if (token == null) {
      print("Token não encontrado. As requisições da despensa falharão.");
      return {
        'Content-Type': 'application/json; charset=UTF-8',
      };
    }
    
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  // Busca ingredientes da despensa (mss-pantry)
  Future<List<Ingrediente>> getPantryIngredients() async {
    final uri = Uri.parse('$_apiGatewayUrl/pantry/ingredients');
    try {
      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((item) => Ingrediente.fromMap(item)).toList();
      } else {
        print("Erro ao buscar ingredientes: ${response.body}");
        throw Exception("Falha ao carregar ingredientes");
      }
    } catch (e) {
      print("Erro em getPantryIngredients: $e");
      throw Exception("Erro de conexão: $e");
    }
  }

  // Adiciona ingrediente (mss-pantry)
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
        print("Erro ao adicionar ingrediente: ${response.body}");
        throw Exception("Falha ao adicionar ingrediente");
      }
    } catch (e) {
      print("Erro em addIngredient: $e");
      throw Exception("Erro de conexão: $e");
    }
  }

  // Remove ingrediente (mss-pantry)
  Future<void> removeIngredient(Ingrediente ingrediente) async {
    final uri = Uri.parse('$_apiGatewayUrl/pantry/ingredients');
    try {
      final headers = await _getHeaders();
      final body = ingrediente.toJson();
      
      // O backend espera um DELETE com body
      final request = http.Request('DELETE', uri)
        ..headers.addAll(headers)
        ..body = body;
        
      final response = await request.send();

      if (response.statusCode != 200) {
         final responseBody = await response.stream.bytesToString();
         print("Erro ao remover ingrediente: $responseBody");
         throw Exception("Falha ao remover ingrediente");
      }
      // Se chegou aqui, foi sucesso (status 200)
    } catch (e) {
      print("Erro em removeIngredient: $e");
      throw Exception("Erro de conexão: $e");
    }
  }

  // Busca sugestões (mss-ingredient-classifier)
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
        print("Erro ao buscar sugestões: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Erro em getSuggestions: $e");
      return [];
    }
  }
}