import 'package:http/http.dart' as http;

class ApiConfig {
  static const String ipAddress = 'http://89.116.38.149:8000';

  // Augmentation du délai d'expiration à 20 secondes
  static Future<String> determineBaseUrl() async {
    try {
      var response = await http.get(Uri.parse('$ipAddress/api/serveurTest')).timeout(Duration(seconds: 20));
      if (response.statusCode == 200) {
        print("ipAddress connected in $ipAddress");
        return '$ipAddress/api';
      } else {
        print('Erreur lors de la connexion à $ipAddress: Status Code ${response.statusCode}');
        return '';
      }
    } catch (error) {
      print('Erreur lors de la connexion à $ipAddress: $error');
      return '';
    }
  }
}
