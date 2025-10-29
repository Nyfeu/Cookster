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
}