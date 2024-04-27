import 'package:application_rano/data/models/anomalie_model.dart';
import 'package:application_rano/data/models/photo_anomalie_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:application_rano/data/services/databases/nia_databases.dart';

class AnomalieRepository {
  final String baseUrl;
  final NiADatabases _niaDatabases = NiADatabases();

  AnomalieRepository({required this.baseUrl});

  Future<List<AnomalieModel>> fetchAnomaleData(String accessToken) async {
    try {
      final anomalie =  getAnomalieData();

      return anomalie;

    } catch (e) {
      // En cas d'erreur lors de la requête HTTP, lancez une exception avec le message d'erreur
      throw Exception('Failed to fetch home page data: $e');
    }
  }

  Future<List<AnomalieModel>> getAnomalieData() async {
    try {
      final Database db = await _niaDatabases.database;
      final List<Map<String, dynamic>> maps = await db.query('anomalie');
      return List.generate(maps.length, (i) {
        return AnomalieModel(
            id: maps[i]['id'],
            idMc: maps[i]['id_mc'] ?? 0 ,
            typeMc: maps[i]['type_mc'],
            dateDeclaration: maps[i]['date_declaration'],
            longitudeMc: maps[i]['longitude_mc'],
            latitudeMc: maps[i]['latitude_mc'],
            descriptionMc: maps[i]['description_mc'],
            clientDeclare: maps[i]['client_declare'],
            cpCommune: maps[i]['cp_commune'],
            commune: maps[i]['commune'],
            status: maps[i]['status'],
            photoAnomalie1: maps[i]['photo_anomalie_1'],
            photoAnomalie2: maps[i]['photo_anomalie_2'],
            photoAnomalie3: maps[i]['photo_anomalie_3'],
            photoAnomalie4: maps[i]['photo_anomalie_4'],
            photoAnomalie5: maps[i]['photo_anomalie_5'],
        );
      });
    } catch (e) {
      throw Exception("Failed to get acceuil data: $e");
    }
  }



  Future<void> createAnomalie(
      String typeMc,
      String dateDeclaration,
      String longitudeMc,
      String latitudeMc,
      String descriptionMc,
      String clientDeclare,
      String cpCommune,
      String commune,
      String status,
      List<String?> imagePaths,
      ) async {
    try {
      final db = await _niaDatabases.database;
      print('Paramètres de la fonction avant l\'insertion :');
      print('Type MC: $typeMc');
      print('Date de déclaration: $dateDeclaration');
      print('Longitude MC: $longitudeMc');
      print('Latitude MC: $latitudeMc');
      print('Description MC: $descriptionMc');
      print('Client déclaré: $clientDeclare');
      print('Code postal de la commune: $cpCommune');
      print('Commune: $commune');
      print('Statut: $status');
      print('Chemins des images: $imagePaths');
      // Insérer une seule ligne avec les chemins d'image correspondant à chaque colonne
      await db.insert(
        'anomalie',
        {
          'type_mc': typeMc,
          'date_declaration': dateDeclaration,
          'longitude_mc': longitudeMc,
          'latitude_mc': latitudeMc,
          'description_mc': descriptionMc,
          'client_declare': clientDeclare,
          'cp_commune': cpCommune,
          'commune': commune,
          'status': status,
          'photo_anomalie_1': imagePaths.length > 0 ? imagePaths[0] : null,
          'photo_anomalie_2': imagePaths.length > 1 ? imagePaths[1] : null,
          'photo_anomalie_3': imagePaths.length > 2 ? imagePaths[2] : null,
          'photo_anomalie_4': imagePaths.length > 3 ? imagePaths[3] : null,
          'photo_anomalie_5': imagePaths.length > 4 ? imagePaths[4] : null,
        },
      );
      await _updateAcceuil(db);
      print('Anomalie insérée avec succès dans la base de données locale');
      // Récupérer les données insérées et les afficher
      final insertedAnomalie = await db.query('anomalie',
          orderBy: 'id DESC', limit: 1); // Récupérer la dernière anomalie insérée
      if (insertedAnomalie.isNotEmpty) {
        print('Données de la dernière anomalie insérée : $insertedAnomalie');
      } else {
        print('Aucune donnée n\'a été trouvée pour la dernière anomalie insérée');
      }
    } catch (e) {
      print('Échec de l\'enregistrement de l\'anomalie dans la base de données locale: $e');
      throw Exception('Échec de l\'enregistrement de l\'anomalie dans la base de données locale: $e');
    }
  }


  Future<void> _updateAcceuil(Database db) async {
    try {
      // Récupérer le nombre total d'anomalies avec le statut 0, 1 ou 2
      final nonTraite = Sqflite.firstIntValue(await db.rawQuery('''
      SELECT COUNT(*) FROM anomalie WHERE status IN (0)
    '''));
      final enCours = Sqflite.firstIntValue(await db.rawQuery('''
      SELECT COUNT(*) FROM anomalie WHERE status IN (1)
    '''));
      final realiser = Sqflite.firstIntValue(await db.rawQuery('''
      SELECT COUNT(*) FROM anomalie WHERE status IN (2)
    '''));

      // Récupérer le nombre total d'anomalies
      final totaleAnomalieResult = await db.rawQuery('''
      SELECT COUNT(*) FROM anomalie
    ''');
      final totaleAnomalie = Sqflite.firstIntValue(totaleAnomalieResult);

      // Mettre à jour les valeurs correspondantes dans la table "acceuil"
      await db.rawUpdate('''
      UPDATE acceuil SET non_traite = ?, en_cours = ?, realise = ?, totale_anomalie = ?
    ''', [nonTraite, enCours, realiser, totaleAnomalie]);
    } catch (e) {
      throw Exception('Échec de la mise à jour de nombre_relever_effectuer: $e');
    }
  }

  // Définir la fonction pour enregistrer les chemins d'image
  // Future<void> saveImageAnomalie(
  //     int idAnomalie,
  //     List<String?> imagePaths,
  //     ) async {
  //   try {
  //     final db = await _niaDatabases.database;
  //
  //     // Insérer les chemins d'images dans la table photAnomalie
  //     int maxLength = 5; // Définir la longueur maximale de la colonne photo_anomalie_x
  //     for (int i = 0; i < maxLength; i++) {
  //       if (i < imagePaths.length) {
  //         // Si l'index est inférieur à la longueur de la liste imagePaths,
  //         // insérer le chemin d'image dans la colonne correspondante
  //         String? imagePath = imagePaths[i];
  //         if (imagePath != null) {
  //           // Vérifier si l'imagePath est non nulle
  //           // Générer dynamiquement le nom de la colonne en fonction de l'index
  //           String columnName = 'photo_anomalie_${i + 1}';
  //           await db.insert(
  //             'photAnomalie',
  //             {
  //               'main_courante_id': idAnomalie,
  //               columnName: imagePath,
  //             },
  //           );
  //         }
  //       } else {
  //         // Si l'index est supérieur ou égal à la longueur de la liste imagePaths,
  //         // insérer null dans la colonne correspondante
  //         String columnName = 'photo_anomalie_${i + 1}';
  //         await db.insert(
  //           'photAnomalie',
  //           {
  //             'main_courante_id': idAnomalie,
  //             columnName: null,
  //           },
  //         );
  //       }
  //     }
  //
  //     print("Images de l'anomalie enregistrées avec succès dans la base de données locale");
  //   } catch (e) {
  //     print('Échec de l\'enregistrement de l\'anomalie dans la base de données locale: $e');
  //     throw Exception('Échec de l\'enregistrement de l\'anomalie dans la base de données locale: $e');
  //   }
  // }

}