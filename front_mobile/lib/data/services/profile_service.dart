import 'dart:convert';                       // Para codificação/decodificação JSON 
import 'package:http/http.dart' as http;     // Para requisições HTTP
import '../models/user_profile.dart';        // Modelo de Usuário

class ProfileService {

  // URL base do serviço de perfil de usuário

  final String _baseUrl = 'http://localhost:2000/profile';

  // Busca o perfil de um usuário específico pelo ID
  // Utiliza token de autenticação para rotas protegidas
  // Lança exceção em caso de falha na requisição - tratada na camada superior

  Future<UserProfile> fetchUserProfile(String userId, String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return UserProfile.fromJson(json.decode(response.body));
    } else {
      try {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Falha ao carregar o perfil.');
      } catch (e) {
        throw Exception('Erro HTTP: ${response.statusCode}');
      }
    }
  }

  // Atualiza os dados do perfil do usuário
  // Envia os dados do formulário como um mapa de chave-valor
  // Utiliza token de autenticação para rotas protegidas
  // Lança exceção em caso de falha na requisição - tratada na camada superior

  Future<void> updateProfileData(
      String userId, Map<String, dynamic> formData, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(formData),
      );

      if (!response.ok) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Erro ao salvar as alterações.');
      }
      

    } catch (err) {
      throw Exception('Falha ao atualizar o perfil: ${err.toString()}');
    }
  }
}

// Extensão para verificar se a resposta HTTP foi bem-sucedida
// Traduz códigos de status 200-299 como sucesso e outros como falha

extension on http.Response {
  bool get ok => statusCode >= 200 && statusCode < 300;
}