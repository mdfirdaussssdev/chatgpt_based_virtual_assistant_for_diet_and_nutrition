import 'package:flutter/material.dart';

class CalorieProgressBar extends StatelessWidget {
  final int currentCalorieIntake;
  final int recommendedCalorieIntake;

  const CalorieProgressBar({
    super.key,
    required this.currentCalorieIntake,
    required this.recommendedCalorieIntake,
  });

  @override
  Widget build(BuildContext context) {
    // Check if recommendedCalorieIntake is greater than zero
    if (recommendedCalorieIntake <= 0) {
      return const Text(
          'Recommended calorie intake must be greater than zero.');
    }

    final progress = currentCalorieIntake / recommendedCalorieIntake;

    return Column(
      children: [
        LinearProgressIndicator(
          value: progress > 1 ? 1 : progress, // Cap at 1 for overconsumption
          backgroundColor: Colors.grey.shade500,
          valueColor: AlwaysStoppedAnimation<Color>(
            progress > 1 ? Colors.red : Colors.blue,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            progress > 1
                ? 'Exceeded by ${(currentCalorieIntake - recommendedCalorieIntake).toInt()} kcal'
                : 'Remaining Calorie Intake: ${(recommendedCalorieIntake - currentCalorieIntake).toInt()} kcal',
            style: TextStyle(
              color: progress > 1 ? Colors.red : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
