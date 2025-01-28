import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Simulating the GiphyGif class you may have
class GiphyGif {
  final String url;

  GiphyGif({required this.url});

  factory GiphyGif.fromJson(Map<String, dynamic> json) {
    return GiphyGif(url: json['images']['original']['url']);
  }
}

// The method to be tested
Future<List<GiphyGif>> _fetchGifs(String searchQuery) async {
  

  // Mock response data
  final mockResponse = jsonEncode({
    'data': [
      {'images': {'original': {'url': 'http://example.com/gif1.gif'}}},
      {'images': {'original': {'url': 'http://example.com/gif2.gif'}}}
    ],
    'pagination': {'offset': 2}
  });

  // Simulating the HTTP response
  final response = http.Response(mockResponse, 200);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    // Parsing and returning the GIFs
    return (data['data'] as List)
        .map((gifData) => GiphyGif.fromJson(gifData))
        .toList();
  } else {
    throw Exception('Failed to load GIFs');
  }
}

void main() {
  test('Test if GIFs are fetched correctly', () async {
    // Call the method with a sample query
    List<GiphyGif> gifs = await _fetchGifs('cats');

    // Verify that GIFs were fetched correctly
    expect(gifs.length, 2); // We expect two GIFs
    expect(gifs[0].url, 'http://example.com/gif1.gif'); // Check the URL of the first GIF
    expect(gifs[1].url, 'http://example.com/gif2.gif'); // Check the URL of the second GIF
  });
}
