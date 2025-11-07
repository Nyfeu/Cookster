import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  String? _userId;
  String? _token;

  final AuthService _authService = AuthService();

  String? get userId => _userId;
  String? get token => _token;
  bool get isAuthenticated => _token != null;

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

  Future<void> register(String name, String email, String password) async {
    try {
      await _authService.register(name, email, password);
      
    } catch (e) {
      rethrow;
    }
  }


  Future<void> logout() async {
    _userId = null;
    _token = null;
    
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('currentUserId');
    prefs.remove('authToken');
    
    notifyListeners();
  }
}