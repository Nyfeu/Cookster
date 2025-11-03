// Em: lib/blocs/auth_bloc.dart

import 'dart:async';
// BehaviorSubject é ensinado na apostila e vem do rxdart [cite: 2562, 2622]
import 'package:rxdart/rxdart.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart'; // Seu serviço continua o mesmo

// A classe Bloc, como ensinada na apostila [cite: 699, 936]
class AuthBloc {
  
  final AuthService _authService = AuthService();
  String? get currentUserId => _userIdController.valueOrNull;
  String? get currentToken => _tokenController.valueOrNull;
  // 1. CONTROLADORES DE STREAM (ESTADO)
  // Usamos BehaviorSubject, como ensinado, para "capturar o último item"
  // e ser "broadcast" por padrão [cite: 2575, 2580, 2626]
  // Eles substituem suas variáveis `_userId` e `_token`.
  final _userIdController = BehaviorSubject<String?>();
  final _tokenController = BehaviorSubject<String?>();

  // 2. STREAMS (SAÍDAS PARA OS WIDGETS)
  // Widgets usarão StreamBuilder para "ouvir" estes streams [cite: 1042]
  // Substituem seus "getters"
  Stream<String?> get userIdStream => _userIdController.stream;
  Stream<String?> get tokenStream => _tokenController.stream;

  // Stream combinada para facilitar a verificação de autenticação
  // (Usa a mesma lógica do 'emailPasswordAreOk' [cite: 2269])
  Stream<bool> get isAuthenticatedStream => 
      _tokenController.stream.map((token) => token != null);

  // Getter para valor síncrono (usando .value do BehaviorSubject [cite: 2629])
  bool get isAuthenticated => _tokenController.value != null;

  // 3. MÉTODOS (ENTRADAS / "EVENTOS")
  // Estes são os métodos que a UI irá chamar.
  // Eles substituem `notifyListeners()` por `_controller.sink.add()` [cite: 834, 1098]
  
  Future<void> login(String email, String password) async {
    try {
      // 1. Chama o serviço (igual ao seu código)
      final responseData = await _authService.login(email, password);
      
      // 2. Processa a resposta (igual ao seu código)
      final userData = responseData['user'] as Map<String, dynamic>?;
      final token = responseData['token'] as String?;
      final userId = userData?['id'] as String?; 

      if (userId == null || token == null) {
        throw Exception('Resposta da API inválida: ID ou Token nulos.');
      }

      // 3. Adiciona os novos valores aos "sinks" para notificar os ouvintes
      _userIdController.sink.add(userId);
      _tokenController.sink.add(token);

      // 4. Salva no SharedPreferences (igual ao seu código)
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('currentUserId', userId);
      prefs.setString('authToken', token);
      
    } catch (e) {
      // Re-lança o erro para a UI tratar (ex: num try-catch no botão)
      print('Erro no AuthBloc (login): $e');
      rethrow;
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      await _authService.register(name, email, password);
      // Opcional: você pode chamar o login aqui
      // await login(email, password);
    } catch (e) {
      print('Erro no AuthBloc (register): $e');
      rethrow; 
    }
  }

  Future<void> logout() async {
    // Atualiza os streams para null, notificando os ouvintes
    _userIdController.sink.add(null);
    _tokenController.sink.add(null);
    
    // Limpa o SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('currentUserId');
    prefs.remove('authToken');
  }

  // Função para tentar auto-login na inicialização do app
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('authToken')) {
      _userIdController.sink.add(null);
      _tokenController.sink.add(null);
      return;
    }
    
    final token = prefs.getString('authToken');
    final userId = prefs.getString('currentUserId');
    
    // Alimenta os streams com os dados salvos
    _userIdController.sink.add(userId);
    _tokenController.sink.add(token);
  }

  // 4. MÉTODO DISPOSE
  // A apostila ensina que os streams devem ser fechados [cite: 947, 965]
  void dispose() {
    _userIdController.close();
    _tokenController.close();
  }
}

// --- PONTO PRINCIPAL ---
// Criação da "Única instância Bloc global", como ensinado na apostila [cite: 1012, 1035]
// Você vai importar esta variável 'authBloc' em toda a sua aplicação.
final authBloc = AuthBloc();