class EatMoreModel {
  String name;
  String iconPath;

  EatMoreModel({
    required this.name,
    required this.iconPath,
  });

  static List<EatMoreModel> getEatMore() {
    List<EatMoreModel> eatMore = [];

    eatMore.add(
      EatMoreModel(
        name: 'Protein (Meat & Others)',
        iconPath: 'assets/images/recipe.svg',
      ),
    );

    eatMore.add(
      EatMoreModel(
        name: 'Healthier Oils & Fats',
        iconPath: 'assets/images/intake.svg',
      ),
    );

    eatMore.add(
      EatMoreModel(
        name: 'Wholegrains',
        iconPath: 'assets/images/nutrition.svg',
      ),
    );

    eatMore.add(
      EatMoreModel(
        name: 'Fruit & Vegetables',
        iconPath: 'assets/images/nutrition.svg',
      ),
    );

    return eatMore;
  }
}
