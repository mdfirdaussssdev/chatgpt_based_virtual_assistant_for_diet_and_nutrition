String generateFoodNutritionPrompt(String food, int servings) {
  return '''
Provide a nutrition breakdown for $servings servings of $food. 
If you cannot find or do not understand the food name, or the query is bad, just reply "Unable to query input, error! Please enter a proper food name.".


Output format:
Food Name
Healthy or Unhealthy
If unhealthy:
Nutritional Values
Reason:

Example:
Chicken Nuggets (1 Serving)
Unhealthy
Calories: 300
Total Fat: 18g  
Saturated Fat: 3g  
Trans Fat: 0g  
Cholesterol: 50mg  
Sodium: 600mg  
Total Carbohydrate: 30g  
Dietary Fiber: 1g  
Total Sugar: 0g  
Protein: 15g  
Reason: High in fat, sodium, and low in dietary fiber.
''';
}
