import 'package:http/http.dart' as http;

class ApiConfig {
  static const String baseUrlLocal = 'http://10.0.2.2:8000/api';
  static const String baseUrlOnline = 'https://192.168.88.177:8000/api';

  static Future<String> determineBaseUrl() async {
    try {
      // Envoie de la requête à la base de données locale
      var responseLocal = await http.get(Uri.parse('$baseUrlLocal/serveurTest'));
      if (responseLocal.statusCode == 200) {
        return baseUrlLocal;
      }

      // Envoie de la requête à la base de données en ligne
      var responseOnline = await http.get(Uri.parse('$baseUrlOnline/serveurTest'));
      if (responseOnline.statusCode == 200) {
        return baseUrlOnline;
      }

      // Si aucune des bases ne renvoie de réponse 200, on retourne une chaîne vide
      return '';
    } catch (error) {
      // En cas d'erreur, on retourne une chaîne vide
      print('Erreur lors de la détermination de la base URL: $error');
      return '';
    }
  }
}
