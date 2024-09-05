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
        iconPath: 'assets/images/sugar.png',
      ),
    );

    eatLess.add(
      EatLessModel(
        name: 'Salt & Sodium',
        iconPath: 'assets/images/salt.png',
      ),
    );

    eatLess.add(
      EatLessModel(
        name: 'Excess Calories',
        iconPath: 'assets/images/unhealthy.png',
      ),
    );

    eatLess.add(
      EatLessModel(
        name: 'Trans & Saturated Fats',
        iconPath: 'assets/images/fats.png',
      ),
    );

    return eatLess;
  }
}
