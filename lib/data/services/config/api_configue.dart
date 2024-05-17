import 'package:http/http.dart' as http;

class ApiConfig {
  static const List<String> ipAddresses = [
    // 'http://192.168.88.177:8000', // Android Emulator
    'http://89.116.38.149:8000',
    // 'http://domainname.test',
    // Ajoutez d'autres adresses IP au besoin
  ];

  static Future<String> determineBaseUrl() async {
    try {
      for (String ipAddress in ipAddresses) {
        try {
          var response = await http.get(Uri.parse('$ipAddress/api/serveurTest')).timeout(Duration(seconds: 5));
          if (response.statusCode == 200) {
            print("ipAddress connected in $ipAddress");
            return '$ipAddress/api';
          }
        } catch (error) {
          print('Erreur lors de la connexion à $ipAddress: $error');
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
