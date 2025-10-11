class Profile {
  final String userId;
  final String bio;
  final String profissao;
  final String fotoPerfil;
  final String email;
  final String name;
  final String descricao;

  Profile({
    required this.userId,
    this.bio = '',
    this.profissao = '',
    this.fotoPerfil = 'default-profile.jpeg',
    this.email = '',
    this.name = '',
    this.descricao = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'bio': bio,
      'profissao': profissao,
      'fotoPerfil': fotoPerfil,
      'email': email,
      'name': name,
      'descricao': descricao,
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      userId: map['userId']?.toString() ?? '',
      bio: map['bio']?.toString() ?? '',
      profissao: map['profissao']?.toString() ?? '',
      fotoPerfil: map['fotoPerfil']?.toString() ?? 'default-profile.jpeg',
      email: map['email']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      descricao: map['descricao']?.toString() ?? '',
    );
  }
}
