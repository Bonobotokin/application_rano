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

  Future<Map<String, dynamic>> getAllClient(String accessToken) async {
    try {
      final Database db = await _niaDatabases.database;
      List<Map<String, dynamic>> rows = await db.rawQuery('''
      SELECT DISTINCT 
        client.id, 
        client.nom, 
        client.prenom, 
        client.adresse, 
        client.commune, 
        client.region, 
        client.telephone_1, 
        client.telephone_2, 
        client.actif, 
        compteur.id AS compteur_id, 
        compteur.marque, 
        compteur.modele, 
        COUNT(CASE WHEN releves.etatFacture = 'Impayé' THEN 1 ELSE NULL END) AS nombre_etat_impaye,
        COUNT(CASE WHEN releves.etatFacture = 'Payé' THEN 1 ELSE NULL END) AS nombre_etat_paye
      FROM releves
      JOIN compteur ON releves.compteur_id = compteur.id 
      JOIN contrat ON releves.contrat_id = contrat.id
      JOIN client ON releves.client_id = client.id
      GROUP BY client.id;
    ''');

      print(rows);
      // Vérifiez si des données ont été récupérées
      if (rows.isNotEmpty) {
        // Créez des listes pour stocker les clients, les compteurs et les nombres d'états de facture impayés
        List<ClientModel> clients = [];
        List<CompteurModel> compteurs = [];
        List<int> nombreEtatImpaye = [];
        List<int> nombreEtatPaye = [];

        // Parcourez chaque ligne de résultat
        for (final row in rows) {
          // Créez un objet CompteurModel pour chaque ligne
          final compteur = CompteurModel(
            id: row['compteur_id'] ?? 0,
            marque: row['marque'] ?? '',
            modele: row['modele'] ?? '',
          );
          // Ajoutez le compteur à la liste des compteurs
          compteurs.add(compteur);
          // Créez un objet ClientModel pour chaque ligne
          final client = ClientModel(
            id: row['id'] ?? 0,
            nom: row['nom'] ?? '',
            prenom: row['prenom'] ?? '',
            adresse: row['adresse'] ?? '',
            commune: row['commune'] ?? '',
            region: row['region'] ?? '',
            telephone_1: row['telephone_1'] ?? '',
            telephone_2: row['telephone_2'],
            actif: row['actif'] ?? false,
          );
          // Ajoutez le client à la liste des clients
          clients.add(client);
          // Ajoutez le nombre d'états de facture impayés à la liste correspondante
          nombreEtatImpaye.add(row['nombre_etat_impaye'] ?? 0);
          nombreEtatPaye.add(row['nombre_etat_paye'] ?? 0);
        }

        return {
          'clients': clients,
          'compteurs': compteurs,
          'nombre': nombreEtatImpaye,
          'payer': nombreEtatPaye, // Utilisation correcte de la clé 'payer'
        };
      } else {
        // Si aucune donnée n'a été trouvée, lancez une exception
        throw Exception('Aucune donnée trouvée.');
      }
    } catch (error) {
      throw Exception('Failed to fetch client data: $error');
    }
  }

  // Future<List<Map<String, dynamic>>>getClientByNumCompteur(int numCompteur) async {
  //   try{
  //     final Database db = await _niaDatabases.database;
  //     List<Map<String, dynamic>> rows = await db.rawQuery('''
  //       SELECT * FROM releves
  //       JOIN compteur ON releves.compteur_id = compteur.id
  //       JOIN contrat ON releves.contrat_id = contrat.id
  //       JOIN client ON releves.client_id = client.id
  //       WHERE compteur.id = ?
  //     ''', [numCompteur]);
  //     return rows;
  //
  //   } catch (error) {
  //     throw Exception('Failed to fetch client data: $error');
  //   }
  // }

  Future<List<Map<String, dynamic>>>getFactureFactureByClient(int numCompteur) async {
    try{
      final Database db = await _niaDatabases.database;
      List<Map<String, dynamic>> factures = await db.rawQuery('''
      SELECT * FROM facture
      WHERE relevecompteur_id = ?
    ''', [numCompteur]);
      return factures;

    } catch (error) {
      throw Exception('Failed to fetch client data: $error');
    }
  }

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

      print(rows);

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

        final releves = rows.map((row) => RelevesModel(
          id: row['id'],
          idReleve: int.tryParse(row['id_releve'].toString()) ?? 0,
          compteurId: int.tryParse(row['compteur_id'].toString()) ?? 0,
          contratId: int.tryParse(row['contrat_id'].toString()) ?? 0,
          clientId: int.tryParse(row['client_id'].toString()) ?? 0,
          dateReleve: row['date_releve'] ?? '',
          volume: row['volume'] ?? 0,
          conso: row['conso'] ?? 0,
          etatFacture: row['etatFacture'] ?? '',
        )).toList();


        print("client : $releves");

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
        etatFacture: row['etatFacture'] ?? '',
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
        etatFacture: row['etatFacture'] ?? '',
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
