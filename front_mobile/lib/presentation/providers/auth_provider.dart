import 'package:flutter/material.dart';                            // Para ChangeNotifier padrão do Flutter
import 'package:shared_preferences/shared_preferences.dart';       // Para persistência simples de dados localmente
import '../../data/services/auth_service.dart';                    // Serviço de autenticação

// AuthProvider gerencia o estado de autenticação do usuário na aplicação.
// Utiliza ChangeNotifier para notificar listeners sobre mudanças de estado (login, logout etc.).
// Armazena o ID do usuário e token de autenticação, além de fornecer métodos para login, registro e logout.
// Camada de serviço (AuthService) é usada para interagir com a API de autenticação e gerenciar o estado
// da camada de apresentação.

class AuthProvider with ChangeNotifier {

  // Dados de autenticação do usuário

  String? _userId;
  String? _token;

  // Instância do serviço de autenticação

  final AuthService _authService = AuthService();

  // Getters para acessar os dados de autenticação

  String? get userId => _userId;
  String? get token => _token;
  bool get isAuthenticated => _token != null;

  // Método para login do usuário 
  // Armazena ID e token, persiste localmente e notifica listeners
  // Lança exceções em caso de falha - tratadas na camada de apresentação

  Future<void> login(String email, String password) async {
    try {
      final responseData = await _authService.login(email, password);
      final userData = responseData['user'] as Map<String, dynamic>?;
      final token = responseData['token'] as String?;
      final userId = userData?['id'] as String?; 

      if (userId == null || token == null) {
        throw Exception('Resposta da API inválida: ID ou Token nulos.');
      }

      _userId = userId;
      _token = token;

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('currentUserId', _userId!);
      prefs.setString('authToken', _token!);
      
      notifyListeners();

    } catch (e) {
      rethrow;
    }
  }

  // Método para registro de novo usuário
  // Lança exceções em caso de falha - tratadas na camada de apresentação

  Future<void> register(String name, String email, String password) async {
    try {
      await _authService.register(name, email, password);
      
    } catch (e) {
      rethrow;
    }
  }

  // Método para logout do usuário
  // Limpa dados de autenticação, remove persistência local e notifica listeners
  // Não lança exceções - logout sempre deve ser bem-sucedido

  Future<void> logout() async {
    _userId = null;
    _token = null;
    
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('currentUserId');
    prefs.remove('authToken');
    
    notifyListeners();
  }
}