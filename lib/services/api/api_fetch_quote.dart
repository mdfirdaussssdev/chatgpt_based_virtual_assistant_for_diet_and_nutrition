import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> fetchQuote() async {
  const url = 'https://zenquotes.io/api/today';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final List<dynamic> quoteData = jsonDecode(response.body);
    return '"${quoteData[0]['q']}" - ${quoteData[0]['a']}';
  } else {
    throw Exception('Failed to load quote');
  }
}
