import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/user_profile.dart'; // Ajuste o caminho

class ProfileService {
  // Apontando para o Gateway local
  final String _baseUrl = 'http://localhost:2000/profile';

  // [MUDANÇA 1] O método agora precisa aceitar o 'token'
  Future<UserProfile> fetchUserProfile(String userId, String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/$userId'),
      headers: {
        'Content-Type': 'application/json',
        // [MUDANÇA 2] Enviar o token no header para o Gateway
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // A API de /profile/:userId retorna { message: '...', data: {...} }
      // Assumindo que UserProfile.fromJson sabe lidar com isso
      return UserProfile.fromJson(json.decode(response.body));
    } else {
      // Tenta decodificar a mensagem de erro da API
      try {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Falha ao carregar o perfil.');
      } catch (e) {
        throw Exception('Erro HTTP: ${response.statusCode}');
      }
    }
  }

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
        // [MUDANÇA] Trocado ErrorDescription por Exception
        throw Exception(errorData['message'] ?? 'Erro ao salvar as alterações.');
      }
      
      // Se chegou aqui, foi bem-sucedido (não precisa retornar nada)
    } catch (err) {
      // Propaga o erro
      throw Exception('Falha ao atualizar o perfil: ${err.toString()}');
    }
  }

  // [NOVO MÉTODO ADICIONADO]
  // Este método assume que o backend terá um endpoint (ex: GET /profile/search?name=...)
  // que retorna uma LISTA de perfis (ex: [{...}, {...}])
  Future<List<UserProfile>> searchProfiles({
    required String token,
    required String name,
  }) async {
    final queryParams = {'name': name};
    // Assumindo um novo endpoint de busca no gateway
    final uri =
        Uri.parse('$_baseUrl/search').replace(queryParameters: queryParams);

    print('[ProfileService] Buscando perfis em: $uri');

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
        
        // Assumindo que a API retorna uma lista de objetos de perfil
        // e que UserProfile.fromJson sabe como tratar CADA item da lista
        // (Isso pode precisar de ajuste dependendo do seu modelo UserProfile.fromJson)
        return body.map((dynamic item) => UserProfile.fromJson(item)).toList();
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(
            errorBody['error'] ?? 'Falha ao buscar perfis: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na conexão durante a busca de perfis: $e');
    }
  }
}

// Extensão para simplificar a verificação de (!response.ok)
extension on http.Response {
  bool get ok => statusCode >= 200 && statusCode < 300;
}