import 'dart:convert';  // Para conversão JSON <-> Map

class Ingrediente {

  // Atributos principais do ingrediente

  final String nome;
  final String categoria;

  Ingrediente({required this.nome, required this.categoria});

  // Sobrescreve o operador de igualdade (`==`) para comparar dois objetos
  // `Ingrediente` com base em conteúdo, não em identidade de instância.

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ingrediente &&
          runtimeType == other.runtimeType &&
          nome == other.nome &&
          categoria == other.categoria;

  // Gera um hash code baseado nos atributos `nome` e `categoria`
  // É usado para permitir que os objetos sejam identificados em coleções

  @override
  int get hashCode => nome.hashCode ^ categoria.hashCode;

  // Converte o objeto `Ingrediente` (JSON) para um Map

  Map<String, dynamic> toMap() {
    return {'nome': nome, 'categoria': categoria};
  }

  // Utiliza o pattern 'factory' para criar uma instância de `Ingrediente` a partir de um Map

  factory Ingrediente.fromMap(Map<String, dynamic> map) {
    return Ingrediente(
      nome: map['nome'] ?? '',
      categoria: map['categoria'] ?? 'Outros',
    );
  }


  String toJson() => json.encode(toMap());

  factory Ingrediente.fromJson(String source) =>
      Ingrediente.fromMap(json.decode(source));
      
}
