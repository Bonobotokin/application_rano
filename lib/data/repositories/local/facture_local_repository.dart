import 'package:sqflite/sqflite.dart';
import 'package:application_rano/data/models/facture_model.dart';
import 'package:application_rano/data/services/databases/nia_databases.dart';
import 'package:intl/intl.dart';

class FactureLocalRepository {
  final NiADatabases _niaDatabases = NiADatabases();


  Future<List<FactureModel>> getFactureDataFromLocalDatabase() async {
    try {
      final Database db = await _niaDatabases.database;
      final List<Map<String, dynamic>> maps = await db.query('facture');
      return List.generate(maps.length, (i) {
        return FactureModel(
          id: maps[i]['id'],
          relevecompteurId: maps[i]['relevecompteur_id'], // Correction de la récupération des valeurs
          numFacture: maps[i]['num_facture'],
          numCompteur: maps[i]['num_compteur'],
          dateFacture: maps[i]['date_facture'],
          totalConsoHT: maps[i]['total_conso_ht'],
          tarifM3: maps[i]['tarif_m3'],
          avoirAvant: maps[i]['avoir_avant'],
          avoirUtilise: maps[i]['avoir_utilise'],
          restantPrecedant: maps[i]['restant_precedant'],
          montantTotalTTC: maps[i]['montant_total_ttc'],
          statut: maps[i]['statut'],
        );
      });
    } catch (e) {
      throw Exception("Failed to get factures data from local database: $e");
    }
  }

  Future<Map<String, dynamic>>  getFactureById(int relevecompteurId) async {
    try {
      final Database db = await _niaDatabases.database;
      print("numCompteur : $relevecompteurId");
      List<Map<String, dynamic>> rows = await db.rawQuery('''
        SELECT * FROM facture
        WHERE num_compteur = ?
      ''',[relevecompteurId]);

      print("factures data : $rows");
      if (rows.isNotEmpty) {
        final row = rows[0];
        final factures =  FactureModel(
          id: row['id'],
          relevecompteurId: row['relevecompteur_id'],
          numFacture: row['num_facture'],
          numCompteur: row['num_compteur'],
          dateFacture: row['date_facture'],
          totalConsoHT: row['total_conso_ht'],
          tarifM3: row['tarif_m3'],
          avoirAvant: row['avoir_avant'],
          avoirUtilise: row['avoir_utilise'],
          restantPrecedant: row['restant_precedant'],
          montantTotalTTC: row['montant_total_ttc'],
          statut: row['statut'],
        );

        return {'factures': factures};

      } else {
      // Si aucune donnée n'a été trouvée, lancez une exception
      throw Exception('Aucune donnée trouvée.');
      }

    } catch (e) {
      throw Exception("Failed to get facture data by ID from local database: $e");
    }
  }
}

