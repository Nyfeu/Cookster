import 'dart:convert';                                          // Para codificação/decodificação JSON 
import 'package:http/http.dart' as http;                        // Para requisições HTTP
import 'package:shared_preferences/shared_preferences.dart';    // Para armazenamento local

class AuthService {

  // URL base do serviço de autenticação

  final String _baseUrl = 'http://localhost:2000/auth';
  static const String _tokenKey = 'auth_token';


  // Salva o token de autenticação localmente usando SharedPreferences
  // Isso permite persistir o estado de login entre sessões da aplicação.
  // Método privado, usado internamente após login ou registro bem-sucedido.

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Recupera o token de autenticação salvo localmente
  // Retorna null se não houver token salvo

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Remove o token de autenticação localmente (logout)

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Realiza o login do usuário com email e senha
  // Utiliza 'dynamic' para o retorno, pois pode variar conforme a API
  // Lança exceção em caso de falha no login - tratada na camada superior

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'email': email, 'password': password}),
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final String token = responseBody['token'];
      await _saveToken(token);
      return responseBody;
    } else {
      throw Exception(responseBody['error'] ?? 'Falha no login');
    }
  }

  // Realiza o registro de um novo usuário com nome, email e senha
  // Utiliza 'dynamic' para o retorno, pois pode variar conforme a API
  // Lança exceção em caso de falha no registro - tratada na camada superior

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
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
      final token = responseBody['token'] as String?;
      if (token != null) {
        await _saveToken(token);
      }

      return responseBody;
    } else {
      throw Exception(responseBody['error'] ?? 'Falha no registro');
    }
  }

}
