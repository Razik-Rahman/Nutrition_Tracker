class FoodItem {
  final String? id; // Maps to MongoDB _id
  final String name;
  final String description;
  final String category;
  final double gram;
  final double protein;
  final double fibre;
  final double calories;

  FoodItem({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.gram,
    required this.protein,
    required this.fibre,
    required this.calories,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      gram: (json['gram'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      fibre: (json['fibre'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'gram': gram,
      'protein': protein,
      'fibre': fibre,
      'calories': calories,
    };
  }
}
