import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> getImageForRecipe(String recipeName) async {
  const apiKey = 'AIzaSyDlRfbxmi7eGVIvaLrfdiuO_duwxWB_c7w';
  const searchEngineId = '70656725772b2439b';

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
