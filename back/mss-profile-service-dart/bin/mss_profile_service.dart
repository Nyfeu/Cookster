import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;
import 'package:mongo_dart/mongo_dart.dart';
import 'package:dotenv/dotenv.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

// mss responsável por gerenciar todos os dados de perfil dos usuários
//(biografia, nome...)

//Segue dois padrões de comunicacao principais: API REST (Sincrona) p/ CRUD
// e arquitetura orientada a servicos (Assincrona): Para reagir a eventos que 
// acontecem em outros mss (como a criacao automatica de perfil quando um novo usuario se registra)

void main(List<String> args) async {

  final env = DotEnv(includePlatformEnvironment: true)..load();
 

  final String appPort = env['SERVICE_PORT'] ?? '5000';
  final String serviceId = 'mss-profile-service';
  final String eventBusUrl = env['EVENT_BUS_URL'] ?? 'http://localhost:4000';
  final String serviceUrl = env['SERVICE_URL'] ?? 'http://localhost';
  final String serviceFullUrl = '$serviceUrl:$appPort';
  const String defaultImageUrl = 'default-profile.jpeg';

  final dbUser = env['DB_USER'];
  final dbPassword = env['DB_PASS'];
  
  if (dbUser == null || dbPassword == null) {
      print('❌ Erro de Configuração: DB_USER ou DB_PASS não foram carregados do ambiente.');
      return;
  }
  

  // Garantir que caracteres especiais não quebrem a URL de conexao
  final encodedUser = Uri.encodeComponent(dbUser.trim());
  final encodedPass = Uri.encodeComponent(dbPassword.trim());
  final mongoUri = 'mongodb+srv://$encodedUser:$encodedPass@cluster0.fbrwz1j.mongodb.net/mss-profile-service?retryWrites=true&w=majority&appName=Cluster0';
  print ('🔑 MongoDB URI: $mongoUri');

 //Conexão com o mongo
  late final Db db;
  try {
    db = await Db.create(mongoUri);
    await db.open();
    print('✅ MongoDB: [OK]');
  } catch (e) {
    print('❌ MongoDB: [FAILED] -> $e');
    return;
  }

 //Definindo a colecao para armazenar os dados
  final profiles = db.collection('profiles');
  final router = Router();


  //Middlewares --> camadas para processar a requisicao antes de chegar a rota final

  final handler = Pipeline()
      .addMiddleware(logRequests()) //Middleware paa logar as requisicoes recebidas --> DEBUG
      .addMiddleware(corsHeaders()) //Middleware para os CORS -> permitir que o front (em outro dominio acesse a API)
      .addHandler(router);


  Response validateProfileUpdate(Map<String, dynamic> body) {
    final name = body['name'];
    final email = body['email'];
   //garantindo os campos obrigatorios
    if (name == null || email == null) {
      return Response(400,
          body: jsonEncode({'message': 'Nome e Email são campos obrigatórios.'}),
          headers: {'Content-Type': 'application/json'});
    }
   //validacao de email com regex
    final emailRegex = RegExp(r'.+@.+\..+');
    if (!emailRegex.hasMatch(email)) {
      return Response(400,
          body: jsonEncode({'message': 'Por favor, insira um endereço de email válido.'}),
          headers: {'Content-Type': 'application/json'});
    }

    return Response.ok('');
  }

//Lógica orientada a eventos
  Future<void> onUserRegistered(Map<String, dynamic> userData) async {
    try {
      final userId = userData['id'];
      final name = userData['name'];
      final email = userData['email'];

      if (userId == null) {
        print("[!] Evento 'UserRegistered' recebido sem userId. Ignorando.");
        return;
      }
//Verifica se já existe o perfil
      final existing = await profiles.findOne(where.eq('userId', userId));
      if (existing != null) {
        print("[x] Perfil para o usuário $userId já existe. Ignorando criação duplicada.");
        return;
      }
//cria um novo perfil
      final newProfile = {
        'userId': userId,
        'bio': 'Olá! Sou ${name ?? 'um novo usuário'}. Bem-vindo(a)!',
        'profissao': 'Não informada',
        'fotoPerfil': defaultImageUrl,
        'email': email ?? '',
        'name': name ?? '',
        'descricao': 'Fale mais sobre você!'
      };

      await profiles.insertOne(newProfile);
      print("[+] Perfil criado automaticamente para o usuário: $userId (Nome: ${name ?? 'N/A'})");
    } catch (e) {
      print('Erro ao processar evento UserRegistered ou criar perfil: $e');
    }
  }

// mapeia os tipos de evento às suas funcoes de tratamento
  final Map<String, Future<void> Function(Map<String, dynamic>)> eventHandlers = {
    'UserRegistered': onUserRegistered,
  };

// CRUD
  router.get('/<userId>', (Request req, String userId) async {
    try {
      final requesterId = req.headers['user-id'];
      
      final profile = await profiles.findOne(where.eq('userId', userId));
      if (profile == null) {
        return Response(404,
            body: jsonEncode({'message': 'Perfil não encontrado para o usuário com ID: $userId'}),
            headers: {'Content-Type': 'application/json'});
      }
      //permite "editar perfil"
      final isOwner = (requesterId == profile['userId']);
      print(requesterId);
      print(profile['userId']);
      print(isOwner);
      if (profile.containsKey('_id')) {
        profile['_id'] = profile['_id'].toString(); //serializando o objectid do mongo para ser serializavel em JSON
      }
      profile['isOwner'] = isOwner;

      return Response.ok(
          jsonEncode({'message': 'Perfil encontrado com sucesso!', 'data': profile}),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      print('Erro ao buscar perfil: $e');
      return Response.internalServerError(
          body: jsonEncode({'message': 'Erro interno do servidor ao buscar perfil.'}),
          headers: {'Content-Type': 'application/json'});
    }
  });

// para criar um novo perfil manualmente
  router.post('/', (Request req) async {
    try {
      final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final userId = body['id'];

      if (userId == null) {
        return Response(400,
            body: jsonEncode({'message': 'O ID do usuário (userId) é obrigatório.'}),
            headers: {'Content-Type': 'application/json'});
      }

      final existing = await profiles.findOne(where.eq('userId', userId));
      if (existing != null) {
        return Response(409,
            body: jsonEncode({'message': 'Um perfil já existe para o usuário com ID: $userId'}),
            headers: {'Content-Type': 'application/json'});
      }

      final newProfile = {
        'userId': userId,
        'bio': body['bio'] ?? '',
        'profissao': body['profissao'] ?? '',
        'fotoPerfil': body['fotoPerfil'] ?? defaultImageUrl,
        'email': body['email'] ?? '',
        'name': body['nome'] ?? body['name'] ?? '',
        'descricao': body['descricao'] ?? ''
      };

      await profiles.insertOne(newProfile);

      if (newProfile.containsKey('_id')) {
        newProfile['_id'] = newProfile['_id'].toString();
      }

      return Response(201,
          body: jsonEncode({'message': 'Perfil criado com sucesso!', 'data': newProfile}),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      print('Erro ao criar perfil: $e');
      return Response.internalServerError(
          body: jsonEncode({'message': 'Erro interno do servidor ao criar perfil.'}),
          headers: {'Content-Type': 'application/json'});
    }
  });

 //atualiza perfil
  router.put('/<userId>', (Request req, String userId) async {
    try {

      final requesterId = req.headers['user-id'];
      //garantindo que um usuario só consiga editar o seu perfil
      if (requesterId == null || requesterId != userId) {
        return Response(403,
            body: jsonEncode({'message': 'Acesso negado. Você só pode editar o seu próprio perfil.'}),
            headers: {'Content-Type': 'application/json'});
      }
      
      final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final validation = validateProfileUpdate(body);
      if (validation.statusCode != 200) return validation;

      final updateFields = <String, dynamic>{};
      for (final key in ['fotoPerfil', 'name', 'email', 'bio', 'descricao']) {
        if (body.containsKey(key)) updateFields[key] = body[key];
      }

      final modifier = ModifierBuilder(); //do mongo_dart para ciar a operacao de update
      updateFields.forEach((key, value) => modifier.set(key, value));

      final result = await profiles.updateOne(where.eq('userId', userId), modifier);
      if (result.nMatched == 0) {
        return Response(404,
            body: jsonEncode({'message': 'Perfil não encontrado.'}),
            headers: {'Content-Type': 'application/json'});
      }

      final updatedProfile = await profiles.findOne(where.eq('userId', userId));

      if (updatedProfile != null && updatedProfile.containsKey('_id')) {
        updatedProfile['_id'] = updatedProfile['_id'].toString();
      }

      return Response.ok(
          jsonEncode({'message': 'Perfil atualizado com sucesso!', 'user': updatedProfile}),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      print('Erro ao atualizar perfil: $e');
      return Response.internalServerError(
          body: jsonEncode({'message': 'Erro interno do servidor ao atualizar o perfil.'}),
          headers: {'Content-Type': 'application/json'});
    }
  });

//ENDPOINT para receber eventos do event-bus

  router.post('/events', (Request req) async {
    try {
      final evento = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      print('[Event Bus] Evento Recebido: Tipo=${evento['type']}, Dados=${evento['payload']}');
//procura a funcao de tratamento correspondente ao tipo do evento
      final handler = eventHandlers[evento['type']];
      if (handler != null) {
        await handler(evento['payload'] as Map<String, dynamic>);
      } else {
        print('[!] Tipo de evento desconhecido: ${evento['type']}.');
      }
    } catch (e) {
      print('Erro ao processar evento do Event Bus: $e');
    }
    return Response.ok('');
  });

//Inicia o http paa escutar as requisicoes na porta definida. 0.0.0.0 Faz com que se aceite
// conexoes de qualquer interface e ede
  await io.serve(handler, '0.0.0.0', int.parse(appPort));
  print('🟢 MSS-PROFILE-SERVICE rodando na porta $appPort');

  try {
    final response = await http.post(
      Uri.parse('$eventBusUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'serviceId': serviceId, 'url': '$serviceFullUrl/events'}),
    );

    if (response.statusCode == 200) {
      print('📡 EVENT-BUS: [REGISTERED]');
    } else {
      print('❌ EVENT-BUS: [FAILED] - ${response.statusCode}');
    }
  } catch (e) {
    print('❌ EVENT-BUS: [FAILED] -> $e');
  }
}