import 'package:application_rano/data/models/client_model.dart';
import 'package:application_rano/data/models/compteur_model.dart';
import 'package:application_rano/data/models/contrat_model.dart';
import 'package:application_rano/data/models/releves_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:application_rano/data/services/databases/nia_databases.dart';

class ClientRepository {
  final String baseUrl;

  final NiADatabases _niaDatabases = NiADatabases();

  ClientRepository({required this.baseUrl});

  Future<Map<String, dynamic>> fetchClientData(
      int numCompteur, String accessToken) async {
    try {
      final Database db = await _niaDatabases.database;
      List<Map<String, dynamic>> rows = await db.rawQuery('''
        SELECT * FROM releves
        JOIN compteur ON releves.compteur_id = compteur.id 
        JOIN contrat ON releves.contrat_id = contrat.id
        JOIN client ON releves.client_id = client.id
        WHERE compteur.id = ?
      ''', [numCompteur]);

      // print(rows);

      // Vérifiez si des données ont été récupérées
      if (rows.isNotEmpty) {
        // Récupérez les données de la première ligne
        final row = rows[0];

        // Créez des objets individuels pour chaque table
        final client = ClientModel(
          id: row['client_id'],
          nom: row['nom'] ?? '',
          prenom: row['prenom'] ?? '',
          adresse: row['adresse'] ?? '',
          commune: row['commune'] ?? '',
          region: row['region'] ?? '',
          telephone_1: row['tephone_1'] ?? '',
          telephone_2: row['tephone_2'] ?? '',
          actif: row['actif'],
        );

        final compteur = CompteurModel(
          id: int.parse(
              row['compteur_id'].toString()), // Conversion de String à int
          marque: row['marque'] ?? '',
          modele: row['modele'] ?? '',
        );

        final contrat = ContratModel(
          id: row['contrat_id'],
          numeroContrat: row['numero_contrat'] ?? '',
          clientId: row['client_id'],
          dateDebut: row['date_debut'] ?? '',
          dateFin: row['date_fin'], // Pas besoin d'utiliser ?? '' ici
          adresseContrat: row['adresse_contrat'] ?? '',
          paysContrat: row['pays_contrat'] ?? '',
        );

        final releves = rows
            .map((row) => RelevesModel(
                  id: row['id'],
                  idReleve: int.parse(row['id_releve'].toString()),
                  compteurId: int.parse(row['compteur_id'].toString()),
                  contratId: int.parse(row['contrat_id'].toString()),
                  clientId: int.parse(row['client_id'].toString()),
                  dateReleve: row['date_releve'] ?? '',
                  volume: row['volume'] ?? 0,
                  conso: row['conso'] ?? 0,
                ))
            .toList();

        print(releves);

        return {
          'client': client,
          'compteur': compteur,
          'contrat': contrat,
          'releves': releves,
        };
      } else {
        // Si aucune donnée n'a été trouvée, lancez une exception
        throw Exception('Aucune donnée trouvée.');
      }
    } catch (error) {
      throw Exception('Failed to fetch client data: $error');
    }
  }

  Future<Map<String, List<RelevesModel>>> getReleverByDate(int numCompteur, String date) async {
    try {
      final Database db = await _niaDatabases.database;

      // 1. Récupérer d'abord les relevés pour la date spécifique
      List<Map<String, dynamic>> specificDateRows = await db.rawQuery('''
      SELECT * FROM releves
      WHERE compteur_id = ? AND date_releve = ?
    ''', [numCompteur, date]);

      // 2. Récupérer ensuite les relevés antérieurs à la date spécifique
      List<Map<String, dynamic>> previousDateRows = await db.rawQuery('''
      SELECT * FROM releves
      WHERE compteur_id = ? AND date_releve < ?
      ORDER BY date_releve DESC
      LIMIT 1
    ''', [numCompteur, date]);


      List<RelevesModel> specificDateReleves = [];
      List<RelevesModel> previousDateReleves = [];

      // Convertir les résultats de la requête en objets RelevesModel
      specificDateReleves = specificDateRows.map((row) => RelevesModel(
        id: row['id'],
        idReleve: row['id_releve'],
        compteurId: int.parse(row['compteur_id'].toString()),
        contratId: row['contrat_id'],
        clientId: row['client_id'],
        dateReleve: row['date_releve'] ?? '',
        volume: row['volume'] ?? 0,
        conso: row['conso'] ?? 0,
      )).toList();

      previousDateReleves = previousDateRows.map((row) => RelevesModel(
        id: row['id'],
        idReleve: row['id_releve'],
        compteurId: int.parse(row['compteur_id'].toString()),
        contratId: row['contrat_id'],
        clientId: row['client_id'],
        dateReleve: row['date_releve'] ?? '',
        volume: row['volume'] ?? 0,
        conso: row['conso'] ?? 0,
      )).toList();

      // Créer un map contenant les deux listes de relevés
      Map<String, List<RelevesModel>> relevesMap = {
        'specificDateReleves': specificDateReleves,
        'previousDateReleves': previousDateReleves,
      };

      return relevesMap;
    } catch (e) {
      print('Error fetching releves: $e');
      throw Exception('Failed to get releves data by date from local database: $e');
    }
  }



}
