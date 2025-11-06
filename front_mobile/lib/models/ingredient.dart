// lib/models/ingrediente_model.dart

import 'dart:convert';

class Ingrediente {
  final String nome;
  final String categoria;

  Ingrediente({
    required this.nome,
    required this.categoria,
  });

  // Para comparar ingredientes na lista
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ingrediente &&
          runtimeType == other.runtimeType &&
          nome == other.nome &&
          categoria == other.categoria;

  @override
  int get hashCode => nome.hashCode ^ categoria.hashCode;

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'categoria': categoria,
    };
  }

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