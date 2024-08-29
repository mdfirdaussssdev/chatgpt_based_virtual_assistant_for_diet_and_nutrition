import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/constants/routes.dart';
import 'package:flutter/material.dart';

class UserMainActionsModel {
  String name;
  String iconPath;
  Color boxColor;
  String routeName;

  UserMainActionsModel({
    required this.name,
    required this.iconPath,
    required this.boxColor,
    required this.routeName,
  });

  static List<UserMainActionsModel> getUserMainActions() {
    List<UserMainActionsModel> userMainActions = [];

    userMainActions.add(
      UserMainActionsModel(
        name: 'Recipe Query',
        iconPath: 'assets/images/recipe.svg',
        boxColor: const Color(0xff9DCEFF),
        routeName: userRecipeQueryRoute,
      ),
    );

    userMainActions.add(
      UserMainActionsModel(
        name: 'User Intake',
        iconPath: 'assets/images/intake.svg',
        boxColor: const Color(0xff5B8BFF),
        routeName: userUserIntakeRoute,
      ),
    );

    userMainActions.add(
      UserMainActionsModel(
        name: 'Food Nutrition',
        iconPath: 'assets/images/nutrition.svg',
        boxColor: const Color(0xff7AB3FF),
        routeName: userFoodNutritionQueryRoute,
      ),
    );

    return userMainActions;
  }
}
