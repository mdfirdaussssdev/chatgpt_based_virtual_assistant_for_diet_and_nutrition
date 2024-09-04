class EatLessModel {
  String name;
  String iconPath;

  EatLessModel({
    required this.name,
    required this.iconPath,
  });

  static List<EatLessModel> getEatLess() {
    List<EatLessModel> eatLess = [];

    eatLess.add(
      EatLessModel(
        name: 'Sugar',
        iconPath: 'assets/images/recipe.svg',
      ),
    );

    eatLess.add(
      EatLessModel(
        name: 'Salt & Sodium',
        iconPath: 'assets/images/intake.svg',
      ),
    );

    eatLess.add(
      EatLessModel(
        name: 'Excess Calories',
        iconPath: 'assets/images/nutrition.svg',
      ),
    );

    eatLess.add(
      EatLessModel(
        name: 'Trans & Saturated Fats',
        iconPath: 'assets/images/nutrition.svg',
      ),
    );

    return eatLess;
  }
}
