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


  Future<void> updateProfileData(String userId, Map<String, dynamic> formData, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',},
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
}

// Extensão para simplificar a verificação de (!response.ok)
extension on http.Response {
  bool get ok => statusCode >= 200 && statusCode < 300;
}