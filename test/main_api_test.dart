import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

// The method to be tested
Future<bool> isApiKeyValid() async {
  final String apiKey = 'WgYVQuRpozwdmDAkdxoljoQicUbpz2Qk';  // Use your API key here
  final url = Uri.parse(
      'https://api.giphy.com/v1/gifs/trending?api_key=$apiKey&limit=1'); // Fetching trending GIFs

  final response = await http.get(url);

  if (response.statusCode == 200) {
    // If the response is OK, the API key is valid
    return true;
  } else if (response.statusCode == 401 || response.statusCode == 403) {
    // If we get a 401 or 403, it means the API key is invalid
    return false;
  } else {
    // Handle other status codes (network issues, server errors, etc.)
    return false;
  }
}

void main() {
  test('Test if API key works with Giphy API', () async {
    // Call the method to check if the API key works
    bool apiKeyIsValid = await isApiKeyValid();

    // Verify that the API key is valid (should return true for a correct API key)
    expect(apiKeyIsValid, true);
  });
}
