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

String getRecipeQueryPrompt(String recipeTitle, String userGoal) {
  return '''
Return the recipe of $recipeTitle. Only return me whats necessary. Please do not add a - or an indexing number for the ingredients
it should just be the ingredient and it's number required. Under Reason:, please also add why it will help in accomplishing $userGoal.

Only return english characters for everything! The Food Name should be the $recipeTitle.

Output format:
Food Name

Reason
Ingredient List (Can this be listed properly so I can count the number of ingredients)
Instructions

Example:
Nasi Lemak 

Reason: reason why it helps in $userGoal. 

Ingredient List: 
3 tbsp sesame oil
3 tbsp soy sauce
3 tbsp rice wine

Instructions:
1. Heat sesame oil 
2. Add sliced garlic, ginger, and dried chilies


''';
}

String getRandomRecipePrompt(String region, String userGoal) {
  return '''
Find a random healthy recipe that you can return to me later from $region that is good for $userGoal. Only return the name of the food. 
Only return english characters for everything!
If $region is an invalid country or region, return 'error'.
''';
}

String getFoodCalorieCountPrompt(
  String foodName,
  int servings,
) {
  return '''
What is the calorie count for the food name $foodName? $servings servings of it. 

Only return an integer value in kcal. NO TEXTS, ONLY THE CALCULATED VALUE RETURNED.

If unable to find the calorie count for the food, return 'food name not found'.
''';
}
