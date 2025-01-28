import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('fetchStickers returns a list of sticker URLs', () async {
    final result = await _fetchStickers();

    // Verify that the result is a list of sticker URLs
    expect(result, isA<List<String>>());
    expect(result.isNotEmpty, true); // Check if the list is not empty
    expect(result[0], startsWith('http')); // Check if the first URL starts with 'http'
  });
}

Future<List<String>> _fetchStickers() async {
  const String apiKey = 'WgYVQuRpozwdmDAkdxoljoQicUbpz2Qk';
  const String url =
      'https://api.giphy.com/v1/stickers/trending?api_key=$apiKey&limit=20';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return (data['data'] as List)
        .map((sticker) => sticker['images']['original']['url'] as String)
        .toList();
  } else {
    throw Exception('Failed to load stickers');
  }
}
