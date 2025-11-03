// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart'; // <-- 1. IMPORTA O SEU SERVIÇO!

class AuthProvider with ChangeNotifier {
  String? _userId;
  String? _token;

  // 2. CRIA UMA INSTÂNCIA DO SEU SERVIÇO
  final AuthService _authService = AuthService();

  // Getters para o resto do app acessar os dados
  String? get userId => _userId;
  String? get token => _token;
  bool get isAuthenticated => _token != null; // Útil para verificar se está logado

// Em: lib/providers/auth_provider.dart

  Future<void> login(String email, String password) async {
    try {
      // 1. Chama o serviço (isto está correto)
      final responseData = await _authService.login(email, password);

      // --- [CORREÇÃO] ---
      // 2. Pega os dados da resposta "aninhada"
      //    A sua API retorna: { "token": "...", "user": { "id": "..." } }
      final userData = responseData['user'] as Map<String, dynamic>?;
      final token = responseData['token'] as String?;
      
      // 3. Pega o ID de dentro do objeto 'user'
      final userId = userData?['id'] as String?; 

      // 4. Verificação de segurança
      if (userId == null || token == null) {
        // Se o ID ou o Token forem nulos, lança um erro claro.
        throw Exception('Resposta da API inválida: ID ou Token nulos.');
      }

      // 5. Atribui os valores (agora sabemos que não são nulos)
      _userId = userId;
      _token = token;

      // 6. Salva no "localStorage" do Flutter (agora seguro)
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('currentUserId', _userId!);
      prefs.setString('authToken', _token!);
      
      // 7. Avisa o app
      notifyListeners();
      // --- [FIM DA CORREÇÃO] ---

    } catch (e) {
      // Se o login falhar, o authService lança uma exceção.
      print('Erro no AuthProvider: $e');
      rethrow; // Re-lança o erro para a tela de Login
    }
  }

  // Função de Registro
  Future<void> register(String name, String email, String password) async {
    try {
      // Chama o serviço de registro
      await _authService.register(name, email, password);
      
      // (Opcional) Você pode fazer o login automático após o registro
      // await login(email, password);

    } catch (e) {
      print('Erro no AuthProvider: $e');
      rethrow; 
    }
  }


  // Função de Logout (continua igual)
  Future<void> logout() async {
    _userId = null;
    _token = null;
    
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('currentUserId');
    prefs.remove('authToken');
    
    notifyListeners();
  }
}