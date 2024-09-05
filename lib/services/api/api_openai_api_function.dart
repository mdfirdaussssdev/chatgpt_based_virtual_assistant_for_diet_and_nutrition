import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/api/ap_openai_api_prompts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String? openAiApiKey = dotenv.env['OPENAI_API_KEY'];

Future<String> getCaloriesFromOpenAI(String food) async {
  final url = Uri.parse('https://api.openai.com/v1/chat/completions');
  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $openAiApiKey',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'model': 'gpt-4o-mini',
      'messages': [
        {'role': 'system', 'content': 'You are a helpful assistant.'},
        {
          'role': 'user',
          'content':
              'How many calories are in $food? Assuming the food is for one serving of an average Singaporean. Only return a value. If unable to return a calorie value, return error. Return format should be "Approximately xxx calories"'
        }
      ],
      'max_tokens': 10,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    // The API's response structure uses an array called choices to hold these different possible responses.
    // Even if you only request one response, it will still be returned in an array with a single item.
    return data['choices'][0]['message']['content'].trim();
  } else {
    print('Error: ${response.statusCode} - ${response.reasonPhrase}');
    print('Response Body: ${response.body}');
    throw Exception('Failed to get calorie info');
  }
}

Future<String> getFoodNutritionFromOpenAI(String food, int servings) async {
  final url = Uri.parse('https://api.openai.com/v1/chat/completions');
  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $openAiApiKey',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'model': 'gpt-4o-mini',
      'messages': [
        {
          'role': 'system',
          'content':
              'You are a helpful assistant that provides nutrition breakdowns.'
        },
        {'role': 'user', 'content': generateFoodNutritionPrompt(food, servings)}
      ],
      'max_tokens': 200,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'].trim();
  } else {
    print('Error: ${response.statusCode} - ${response.reasonPhrase}');
    print('Response Body: ${response.body}');
    throw Exception('Failed to get calorie info');
  }
}
