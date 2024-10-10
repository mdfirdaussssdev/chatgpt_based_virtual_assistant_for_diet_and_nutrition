import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/api/api_openai_api_function.dart';

class UserIntakeHelper {
  static int calculateAge(DateTime dateOfBirth) {
    final today = DateTime.now();
    int age = today.year - dateOfBirth.year;

    // Adjust age if the user has not yet had their birthday this year
    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }

    return age;
  }

  static int calculateRecommendedCalorieIntake(
    String gender,
    int weight,
    int height,
    int age,
    String activityLevel,
    String goal,
  ) {
    double bmr;

    // Calculate BMR based on gender
    if (gender.toLowerCase() == 'male') {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else if (gender.toLowerCase() == 'female') {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    } else {
      throw ArgumentError('Invalid gender provided: $gender');
    }

    // Define activity factors
    double activityFactor;
    switch (activityLevel.toLowerCase()) {
      case 'sedentary':
        activityFactor = 1.2;
        break;
      case 'lightly active':
        activityFactor = 1.375;
        break;
      case 'moderately active':
        activityFactor = 1.55;
        break;
      case 'very active':
        activityFactor = 1.725;
        break;
      case 'super active':
        activityFactor = 1.9;
        break;
      default:
        throw ArgumentError('Invalid activity level provided: $activityLevel');
    }

    // Calculate total calorie intake
    double totalCalories = bmr * activityFactor;

    // Adjust calories based on goal
    if (goal.toLowerCase() == 'lose weight') {
      totalCalories -= 500; // Subtract 500 kcal for weight loss
    } else if (goal.toLowerCase() == 'gain weight') {
      totalCalories += 300; // Add 300 kcal for weight gain
    } else if (goal.toLowerCase() != 'maintain weight') {
      throw ArgumentError('Invalid goal provided: $goal');
    }

    return totalCalories.round(); // Return calculated value
  }

  // Function to generate explanation based on current calorie intake
  static Future<String> generateExplanation(
      int currentCalorieIntake, int recommendedCalorieIntake) async {
    if (currentCalorieIntake == 0) {
      return "Please enter your meals to keep track of your calorie intake.";
    } else {
      return await generateExplanationForCalorieIntakeFromOpenAI(
          currentCalorieIntake, recommendedCalorieIntake);
    }
  }
}
