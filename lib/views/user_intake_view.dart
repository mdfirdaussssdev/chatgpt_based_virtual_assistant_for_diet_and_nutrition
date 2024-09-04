import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/api/api_openai_api_function.dart';
import 'package:flutter/material.dart';

class UserIntakeView extends StatefulWidget {
  @override
  _UserIntakeViewState createState() => _UserIntakeViewState();
}

class _UserIntakeViewState extends State<UserIntakeView> {
  String? selectedMeal;
  TextEditingController foodController = TextEditingController();
  String? calorieResult;

  Future<void> fetchCalorieInfo(String food) async {
    try {
      String result = await getCaloriesFromOpenAI(food);
      setState(() {
        calorieResult = result;
      });
    } catch (e) {
      setState(() {
        calorieResult = 'Error fetching calorie info';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Intake'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: selectedMeal,
              hint: Text('Select Meal'),
              items: ['Breakfast', 'Lunch', 'Dinner']
                  .map((meal) => DropdownMenuItem(
                        value: meal,
                        child: Text(meal),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedMeal = value;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: foodController,
              decoration: InputDecoration(labelText: 'What did you eat?'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                fetchCalorieInfo(foodController.text);
              },
              child: Text('Get Calorie Info'),
            ),
            SizedBox(height: 16),
            if (calorieResult != null)
              Text(
                'Calories: $calorieResult',
                style: TextStyle(fontSize: 18),
              ),
          ],
        ),
      ),
    );
  }
}
