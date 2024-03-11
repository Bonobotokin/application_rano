import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:application_rano/data/models/user.dart';
import 'package:application_rano/data/services/config/api_configue.dart';
import 'package:application_rano/data/repositories/local/synchronisation_repository.dart';

class SyncService {
  final SynchronisationRepository _synchronisationRepository =
      SynchronisationRepository();

  Future<bool?> syncUsers() async {
    try {
      // Récupérer la base URL dynamiquement
      final baseUrl = await ApiConfig.determineBaseUrl();

      if (baseUrl.isNotEmpty) {
        final response = await getUserDistant(baseUrl);
        if (response.statusCode == 200 || response.statusCode == 201) {
          List<User> users = parseUsersFromResponse(response.body);

          await _synchronisationRepository.insertOrUpdateUsers(users);
          return true;
        } else {
          print(
              'Échec de la synchronisation des données avec le serveur: ${response.statusCode}');
          return false;
        }
      } else {
        print('Aucune URL de base valide trouvée.');
        return false;
      }
    } catch (error) {
      print('Erreur lors de la synchronisation des utilisateurs: $error');
      return false;
    }
  }

  Future<http.Response> getUserDistant(String baseUrl) async {
    // Implémentez la logique pour récupérer les utilisateurs depuis le serveur distant
    final response = await http.get(
      Uri.parse('$baseUrl/getUsers'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    return response;
  }

  List<User> parseUsersFromResponse(String responseBody) {
    // Implémentez la logique pour convertir la réponse en une liste d'utilisateurs
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<User>((json) => User.fromJson(json)).toList();
  }

  Future<bool?> syncData(String accesTOken) async {}
}
