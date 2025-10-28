import 'dart:convert';

class UserProfile {
  final String id;
  final String name;
  final String bio;
  final String profissao;
  final String email;
  final String fotoPerfil;
  final String descricao;
  // Adicione seguidores, seguindo, etc., se eles vierem da API
  // final int seguidores;
  // final int seguindo;

  UserProfile({
    required this.id,
    required this.name,
    required this.bio,
    required this.profissao,
    required this.email,
    required this.fotoPerfil,
    required this.descricao,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // A API do código React retorna um objeto { data: { ... } }
    final data = json['data']; 
    return UserProfile(
      id: data['_id'], // Supondo que o ID venha como _id
      name: data['name'] ?? 'Nome de usuário',
      bio: data['bio'] ?? 'Sem bio',
      profissao: data['profissao'] ?? 'Sem profissão',
      email: data['email'] ?? 'Sem email',
      fotoPerfil: data['fotoPerfil'] ?? '',
      descricao: data['descricao'] ?? 'Sem descrição.',
    );
  }
}