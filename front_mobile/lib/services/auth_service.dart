import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // ATENÇÃO:
  // Usamos 10.0.2.2 para acessar o localhost da sua máquina (onde o API Gateway está)
  // a partir do Emulador Android.
  // Se estiver usando um Simulador iOS, use: 'http://localhost:2000/auth'
  // Se estiver em um dispositivo físico, use o IP da sua máquina na rede: 'http://SEU_IP_DE_REDE:2000/auth'
  final String _baseUrl = 'http://localhost:2000/auth';

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
      return responseBody;
    } else {
      // Erro
      throw Exception(responseBody['error'] ?? 'Falha no login');
    }
  }

  // Método para Registro
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
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
      return responseBody;
    } else {
      // Erro (Ex: email já existe, senha fraca)
      throw Exception(responseBody['error'] ?? 'Falha no registro');
    }
  }
}