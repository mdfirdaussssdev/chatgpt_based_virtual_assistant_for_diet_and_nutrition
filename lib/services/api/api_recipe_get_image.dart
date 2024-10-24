import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> getImageForRecipe(String recipeName) async {
  // const apiKey = ; add own API key
  // const searchEngineId = ; add own searchEngineId

  final url = Uri.parse(
    'https://www.googleapis.com/customsearch/v1?q=$recipeName&cx=$searchEngineId&searchType=image&key=$apiKey',
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final imageUrl = data['items'][0]['link'];
    return imageUrl ?? 'No image found';
  } else {
    return 'Failed to get an image.';
  }
}
