import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:application_rano/data/models/user.dart';
import 'package:application_rano/data/services/databases/nia_databases.dart';
import 'package:application_rano/data/repositories/local/authentification_locale.dart';
import 'package:sqflite/sqflite.dart';

class SynchronisationRepository {
  final NiADatabases _niaDatabases = NiADatabases();

  Future<void> insertOrUpdateUsers(List<User> users) async {
    try {
      final Database db = await _niaDatabases.database;
      Batch batch = db.batch();
      users.forEach((user) async {
        // Vérifiez d'abord si l'utilisateur existe dans la base de données
        List<Map<String, dynamic>> result = await db.query(
          'users',
          where: 'num_utilisateur = ?',
          whereArgs: [user.numUtilisateur],
        );

        if (result.isNotEmpty) {
          // L'utilisateur existe déjà, effectuez une mise à jour
          await db.update(
            'users',
            user.toMap(),
            where: 'num_utilisateur = ?',
            whereArgs: [user.numUtilisateur],
          );
        } else {
          // L'utilisateur n'existe pas encore, effectuez une insertion
          batch.insert(
            'users',
            user.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
      await batch.commit(noResult: true);
    } catch (error) {
      throw Exception("Failed to save users to local database: $error");
    }
  }

  Future<void> synchronisationData(String? accessToken, String? baseUrl) async {
    try {
      final Database db = await _niaDatabases.database;
      print('synchronisation data');
      // Récupérer les données de la table "acceuil"
      final List<Map<String, dynamic>> acceuil = await db.query('acceuil');

      // Convertir les données en JSON
      String acceuilJson = jsonEncode(acceuil);
      print(acceuilJson);
      String apiUrl = '$baseUrl/synchronisation';

      // Construction du corps de la requête
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      // Ajout du champ "acceuil" au corps de la requête
      request.fields['acceuil'] = acceuilJson;

      // Ajout du token d'authentification à l'en-tête
      request.headers['Authorization'] = 'Bearer $accessToken';

      // Envoi de la requête
      var response = await request.send();

      // Vérifier le code de réponse
      if (response.statusCode == 200) {
        // Traitement réussi
        print('Synchronization successful');
      } else {
        // Traitement échoué
        print(
            'Synchronization failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      // Gestion des erreurs
      print('Error during synchronization: $e');
    }
  }
}
