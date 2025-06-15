class MenuEntity {
  final String category;
  final String date;
  String? id;
  List<MenuRecipe> recipes;
  String status;
  double? totalPrice;
  final String type;

  MenuEntity({
    required this.category,
    required this.date,
    this.id,
    required this.recipes,
    required this.status,
    this.totalPrice,
    required this.type,
  });

  factory MenuEntity.fromJson(Map<String, dynamic> json) {
    var recipesFromJson = json['recipes'] as List<dynamic>? ?? [];

    List<MenuRecipe> parsedRecipes = recipesFromJson
        .map((r) => MenuRecipe.fromJson(r as Map<String, dynamic>))
        .toList();

    return MenuEntity(
      id: json['id'] as String? ?? 'N/A',
      category: json['category'] as String? ?? 'N/A',
      type: json['type'] as String? ?? 'N/A',
      status: json['status'] as String? ?? 'N/A',
      date: json['date'] as String? ?? 'N/A',
      totalPrice: json['totalPrice'] as double,
      recipes: parsedRecipes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'date': date,
      'recipes': recipes.map((r) => r.toJson()).toList(),
      'status': status,
      'type': type,
    };
  }
}

class MenuRecipe {
  String? id;
  String? name;
  double? price;

  MenuRecipe({
    required this.id,
    this.name,
    this.price,
  });

  factory MenuRecipe.fromJson(Map<String, dynamic> json) {
    return MenuRecipe(
        id: json['id'] as String? ?? 'N/A',
        name: json['name'] as String? ?? 'N/A',
        price: json['price'] as double? ?? 0);
  }

  Map<String, dynamic> toJson() {
    if (price == null) {
      return {'id': id}; // Default value if price is null
    } else {
      return {
        'id': id,
        'price': price,
      };
    }
  }
}
