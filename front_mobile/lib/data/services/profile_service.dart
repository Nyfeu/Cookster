import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';

class ProfileService {
  final String _baseUrl = 'http://localhost:2000/profile';

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

  Future<List<UserProfile>> searchProfiles({
    required String token,
    required String name,
  }) async {
    final queryParams = {'name': name};
    final uri =
        Uri.parse('$_baseUrl/search').replace(queryParameters: queryParams);


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

extension on http.Response {
  bool get ok => statusCode >= 200 && statusCode < 300;
}