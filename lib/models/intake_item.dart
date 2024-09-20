class IntakeItem {
  final String name;
  final int calories;
  final int servings;

  IntakeItem({
    required this.name,
    required this.calories,
    required this.servings,
  });

  @override
  String toString() {
    return 'IntakeItem(name: $name, calories: $calories, servings: $servings)';
  }

  factory IntakeItem.fromMap(Map<String, dynamic> data) {
    return IntakeItem(
      name: data['name'] ?? '',
      calories: data['calories'] ?? 0,
      servings: data['servings'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
      'servings': servings,
    };
  }
}
