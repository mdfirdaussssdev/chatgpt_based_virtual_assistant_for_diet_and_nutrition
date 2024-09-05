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
        iconPath: 'assets/images/protein.png',
      ),
    );

    eatMore.add(
      EatMoreModel(
        name: 'Healthier Oils & Fats',
        iconPath: 'assets/images/oil.png',
      ),
    );

    eatMore.add(
      EatMoreModel(
        name: 'Wholegrains',
        iconPath: 'assets/images/bread.png',
      ),
    );

    eatMore.add(
      EatMoreModel(
        name: 'Fruit & Vegetables',
        iconPath: 'assets/images/vegetables.png',
      ),
    );

    return eatMore;
  }
}
