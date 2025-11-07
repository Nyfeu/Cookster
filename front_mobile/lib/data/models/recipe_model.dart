import 'dart:convert';

Recipe recipeFromJson(String str) => Recipe.fromJson(json.decode(str));

class Recipe {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String prepTime;
  final String cookTime;
  final int servings;
  final String imageUrl;
  final List<String> tags;
  final List<String> steps;
  final List<Ingredient> ingredients;
  final List<String> utensils;

  Recipe({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.imageUrl,
    required this.tags,
    required this.steps,
    required this.ingredients,
    required this.utensils,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    id: json["_id"] ?? '',
    userId: json["user_id"] ?? 'Usuário',
    name: json["name"] ?? 'Sem nome',
    description: json["description"] ?? '',
    prepTime: (json["prep_time"] ?? 'N/A').toString(),
    cookTime: (json["cook_time"] ?? 'N/A').toString(),
    servings: json["servings"] ?? 0,
    imageUrl: json["image_url"] ?? '',
    tags: List<String>.from(json["tags"] ?? []),
    steps: List<String>.from(json["steps"] ?? []),
    ingredients: List<Ingredient>.from(
      (json["ingredients"] ?? []).map((x) => Ingredient.fromJson(x)),
    ),
    utensils: List<String>.from(json["utensils"] ?? []),
  );
}

class Ingredient {
  final String name;
  final dynamic quantity;
  final String unit;
  final String? note;

  Ingredient({
    required this.name,
    required this.quantity,
    required this.unit,
    this.note,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
    name: json["name"] ?? 'Ingrediente',
    quantity: json["quantity"] ?? 0,
    unit: json["unit"] ?? '',
    note: json["note"],
  );
}
