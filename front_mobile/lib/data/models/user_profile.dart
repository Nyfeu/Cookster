class UserProfile {

  // Atributos principais do perfil do usuário

  final String id;
  final String name;
  final String bio;
  final String profissao;
  final String email;
  final String fotoPerfil;
  final String descricao;
  final bool isOwner;

  UserProfile({
    required this.id,
    required this.name,
    required this.bio,
    required this.profissao,
    required this.email,
    required this.fotoPerfil,
    required this.descricao,
    required this.isOwner,
  });

  // Factory constructor para criar uma instância de UserProfile a partir de um JSON

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return UserProfile(
      id: data['userId'],
      name: data['name'] ?? 'Nome de usuário',
      bio: data['bio'] ?? 'Sem bio',
      profissao: data['profissao'] ?? 'Sem profissão',
      email: data['email'] ?? 'Sem email',
      fotoPerfil: data['fotoPerfil'] ?? '',
      descricao: data['descricao'] ?? 'Sem descrição.',
      isOwner: data['isOwner'] ?? false,
    );
  }
  
}
