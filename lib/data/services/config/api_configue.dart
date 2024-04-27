import 'package:http/http.dart' as http;

class ApiConfig {
  static const List<String> ipAddresses = [
    // 'http://10.0.2.2:8000',
    'http://192.168.0.102:8000',
    // Ajoutez d'autres adresses IP au besoin
  ];

  static Future<String> determineBaseUrl() async {
    try {
      for (String ipAddress in ipAddresses) {
        var response = await http.get(Uri.parse('$ipAddress/api/serveurTest'));
        if (response.statusCode == 200) {
          print("ipAddress connected in $ipAddress");
          return '$ipAddress/api';
        }
      }

      // Si aucune des adresses IP n'est disponible, retournez une chaîne vide
      return '';
    } catch (error) {
      // En cas d'erreur, retournez une chaîne vide
      print('Erreur lors de la détermination de la base URL: $error');
      return '';
    }
  }
}
