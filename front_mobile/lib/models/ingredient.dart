// --- Modelo de Dados (Assumindo esta estrutura) ---
class Ingrediente {
  final String nome;
  final String categoria;

  Ingrediente({required this.nome, required this.categoria});

  factory Ingrediente.fromJson(Map<String, dynamic> json) {
    return Ingrediente(
      nome: json['nome'],
      categoria: json['categoria'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'categoria': categoria,
    };
  }
}