import 'package:http/http.dart' as http;
import 'dart:convert';

const String openAiApiKey =
    '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';

Future<String> getCaloriesFromOpenAI(String food) async {
  final url = Uri.parse('https://api.openai.com/v1/chat/completions');
  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $openAiApiKey',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {'role': 'system', 'content': 'You are a helpful assistant.'},
        {'role': 'user', 'content': 'How many calories are in $food?'}
      ],
      'max_tokens': 50,
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
