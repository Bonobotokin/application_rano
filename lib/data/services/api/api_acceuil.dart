import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiAcceuil {
  final String baseUrl;

  ApiAcceuil({required this.baseUrl});

  Future<Map<String, dynamic>> fetchHomeData(String accessToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/accueil'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch home data: ${response.statusCode}');
    }
  }
}
