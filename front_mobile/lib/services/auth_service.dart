// lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Importar

class AuthService {
  // ATENÇÃO:
  // Usamos 10.0.2.2 para acessar o localhost da sua máquina (onde o API Gateway está)
  // a partir do Emulador Android.
  // Se estiver usando um Simulador iOS, use: 'http://localhost:2000/auth'
  // Se estiver em um dispositivo físico, use o IP da sua máquina na rede: 'http://SEU_IP_DE_REDE:2000/auth'
  
  // Corrigido para 10.0.2.2 para ser consistente com o PantryService no Emulador Android
  final String _baseUrl = 'http://localhost:2000/auth'; 

  static const String _tokenKey = 'auth_token'; // Chave para salvar o token

  // NOVO: Método para salvar o token
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // NOVO: Método para buscar o token (estático, como usado no PantryService)
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // NOVO: Método para Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    // Aqui você também notificaria o AuthProvider para atualizar o estado da UI
  }

  // Método para Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Sucesso
      final String token = responseBody['token'];
      await _saveToken(token); // Salva o token
      return responseBody;
    } else {
      // Erro
      throw Exception(responseBody['error'] ?? 'Falha no login');
    }
  }

  // Método para Registro
  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 201) {
      // Sucesso
      final String token = responseBody['token'];
      await _saveToken(token); // Salva o token
      return responseBody;
    } else {
      // Erro (Ex: email já existe, senha fraca)
      throw Exception(responseBody['error'] ?? 'Falha no registro');
    }
  }
}