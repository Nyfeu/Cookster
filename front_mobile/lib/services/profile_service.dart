import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/user_profile.dart'; // Ajuste o caminho

class ProfileService {
  final String _baseUrl = 'http://localhost:5000/profile'; // Use 10.0.2.2 para emulador Android

  Future<UserProfile> fetchUserProfile(String userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/$userId'),
      headers: {
        'Content-Type': 'application/json',
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