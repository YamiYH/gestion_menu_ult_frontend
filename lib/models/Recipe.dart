///RecipeRequest
class Recipe {
  final double calories;
  final double carbs;
  final String category;
  final String cooking;
  final int cookingTime;
  final double fat;
  final String id;
  final List<RecipeIngredient> ingredients;
  final String name;
  final String observations;
  final String preparation;
  final double protein;
  final int temperature;
  final double totalWeight;

  Recipe({
    required this.calories,
    required this.carbs,
    required this.category,
    required this.cooking,
    required this.cookingTime,
    required this.fat,
    required this.id,
    required this.ingredients,
    required this.name,
    required this.observations,
    required this.preparation,
    required this.protein,
    required this.temperature,
    required this.totalWeight,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    var ingredientsFromJson = json['ingredients'] as List<dynamic>? ?? [];
    List<RecipeIngredient> parsedIngredients = ingredientsFromJson
        .map((r) => RecipeIngredient.fromJson(r as Map<String, dynamic>))
        .toList();

    return Recipe(
      id: json['id'] as String? ?? 'N/A',
      name: json['name'] as String? ?? 'N/A',
      category: json['category'] as String? ?? 'N/A',
      totalWeight: json['totalWeight'] ?? 'N/A',
      calories: json['calories'] ?? 'N/A',
      protein: json['protein'] ?? 'N/A',
      fat: json['fat'] ?? 'N/A',
      carbs: json['carbs'] ?? 'N/A',
      cookingTime: json['cookingTime'] ?? 'N/A',
      temperature: json['temperature'] ?? 'N/A',
      preparation: json['preparation'] as String? ?? 'N/A',
      cooking: json['cooking'] as String? ?? 'N/A',
      observations: json['observations'] as String? ?? 'N/A',
      ingredients: parsedIngredients,
    );
  }
}

///RecipeIngredientRequest
class RecipeIngredient {
  final String id;
  final double netWeight;
  final String product;
  final String productName;
  final double weight;

  RecipeIngredient({
    required this.id,
    required this.netWeight,
    required this.product,
    required this.weight,
    required this.productName,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
        id: json['id'] as String? ?? 'N/A',
        netWeight: json['netWeight'] ?? 'N/A',
        product: json['product'] as String? ?? 'N/A',
        weight: json['weight'] ?? 'N/A',
        productName: json['productName'] as String? ?? 'N/A');
  }
}
