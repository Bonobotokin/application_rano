import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:image/image.dart' as img;
import '../../models/missions_model.dart';
import '../config/api_configue.dart';
import '../databases/nia_databases.dart';

class MissionData {
  final NiADatabases _niaDatabase = NiADatabases();

  static Future<void> sendLocalDataToServer(
      MissionModel mission, String? accessToken) async {
    try {
      String baseUrl = 'http://89.116.38.149:8000/api'; // Déclarez baseUrl comme une variable locale
      final url = '$baseUrl/missions';
      final headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'multipart/form-data',
      };

      // Récupérer les informations de relevé de la mission
      final releveMission =
      await getReleverMission(mission.numCompteur, NiADatabases());

      print("NumCOmpteur envoie ${mission.numCompteur}");

      // Vérifier si des données ont été récupérées
      if (releveMission.isNotEmpty && releveMission.containsKey('imagePath')) {
        final imagePath = releveMission['imagePath'];

        // Créer un objet File à partir du chemin du fichier image_compteur
        final imageCompteurFile = File(imagePath);

        // Vérifier si le fichier existe avant de l'envoyer
        if (imageCompteurFile.existsSync()) {

          print("date sent ${mission.dateReleve.toString()}");
          // Créer une requête multipart
          var request = http.MultipartRequest('POST', Uri.parse(url))
            ..headers.addAll(headers)
            ..fields['num_compteur'] = mission.numCompteur.toString()
            ..fields['date_releve'] = mission.dateReleve.toString()
            ..fields['volume'] = mission.volumeDernierReleve.toString()
            ..files.add(await http.MultipartFile.fromPath(
                'image_compteur', imageCompteurFile.path));

          // Envoyer la requête
          var response = await request.send();

          // Lire le corps de la réponse
          var responseBody = await response.stream.bytesToString();

          // Vérifier la réponse
          if (response.statusCode == 201 || response.statusCode == 200) {
            print('Mission envoyée avec succès !');
          } else {
            print(
                'Erreur lors de l\'envoi de la mission: ${response.statusCode}');
            print('Réponse du serveur: $responseBody');
          }
        } else {
          print('Le fichier image_compteur n\'existe pas.');
        }
      } else {
        print('Aucune donnée de relevé de mission trouvée.');
      }
    } catch (e) {
      print('Erreur lors de l\'envoi de la mission: $e');
    }
  }

  static Future<Map<String, dynamic>> getReleverMission(
      int? numCompteur, NiADatabases _niaDatabase) async {
    try {
      final Database db = await _niaDatabase.database;
      List<Map<String, dynamic>> rows = await db.rawQuery('''
        SELECT image_compteur
        FROM releves 
        WHERE compteur_id = ? AND image_compteur != 'null' AND image_compteur != '' AND image_compteur != '/media/%20'
      ''', [numCompteur]);

      print("Verrifie image_compter ${rows}");
      if (rows.isNotEmpty) {
        final String? imageCompteurPath =
        rows[0]['image_compteur'] as String?;

        if (imageCompteurPath != null && imageCompteurPath.isNotEmpty) {
          final String imagePath =
          await _buildImagePath(imageCompteurPath);

          final File imageFile = File(imagePath);

          if (imageFile.existsSync()) {
            return {
              'imagePath': imagePath,
              'rowData': rows[0],
            };
          } else {
            print("Le fichier image_compteur n'existe pas.");
          }
        } else {
          print("Le chemin du fichier image_compteur est null ou vide.");
        }
      } else {
        throw Exception('Aucune donnée trouvée.');
      }
    } catch (e) {
      print('Erreur lors de la récupération du relevé de la mission: $e');
    }
    return {};
  }

  static Future<String> _buildImagePath(String imageCompteurPath) async {
    if (!imageCompteurPath.startsWith('/')) {
      final Directory appDirectory = await getApplicationDocumentsDirectory();
      return '${appDirectory.path}/$imageCompteurPath';
    }
    return imageCompteurPath;
  }
}
