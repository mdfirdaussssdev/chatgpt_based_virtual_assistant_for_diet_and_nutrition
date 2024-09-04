import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/models/eat_less_model.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/models/eat_more_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UserFoodNutritionView extends StatefulWidget {
  const UserFoodNutritionView({super.key});

  @override
  State<UserFoodNutritionView> createState() => _UserFoodNutritionViewState();
}

class _UserFoodNutritionViewState extends State<UserFoodNutritionView> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: appBar(context),
      body: Column(
        children: [Container()],
      ),
    );
  }
}

AppBar appBar(BuildContext context) {
  return AppBar(
    title: const Text(
      'Food Nutrition',
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
