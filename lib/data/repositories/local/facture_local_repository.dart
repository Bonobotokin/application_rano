import 'package:application_rano/data/models/facture_payment_model.dart';
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
          montantPayer: maps[i]['montant_total_ttc'],
          statut: maps[i]['statut'],
        );
      });
    } catch (e) {
      throw Exception("Failed to get factures data from local database: $e");
    }
  }

  Future<Map<String, dynamic>> getStatuPaymentFacture(int idFacture) async {
    try{
      print("iddddddd $idFacture");
      final Database db = await _niaDatabases.database;
      print("numCompteur : $idFacture");
      List<Map<String, dynamic>> rows = await db.rawQuery('''
        SELECT * FROM facture_paiment
        WHERE facture_id = ? 
      ''',[idFacture]);

      print("getStatuPaymentFacture datas : $rows");
      if (rows.isNotEmpty) {
        final row = rows[0];
        final payment =  FacturePaymentModel(
          id: row['id'],
          factureId: row['facture_id'],
          relevecompteurId: row['relevecompteur_id'],
          paiement: row['paiement'],
          datePaiement: row['date_paiement'],
          statut: row['statut'],
        );

        return {'payment': payment};

      } else {
        final emptyPayment = FacturePaymentModel(
          id: 0,
          factureId: 0,
          relevecompteurId: 0,
          paiement: 0.0,
          datePaiement: '',
          statut: '0',
        );

        return {'payment': emptyPayment};
      }
    } catch (e) {
      throw Exception("Failed to get Statut payment facture data from local database: $e");
    }
  }

  Future<Map<String, dynamic>>  getFactureById(int relevecompteurId) async {
    try {
      print("ID releveCOmpteur $relevecompteurId");
      final Database db = await _niaDatabases.database;
      print("numCompteur : $relevecompteurId");
      List<Map<String, dynamic>> rows = await db.rawQuery('''
        SELECT * FROM facture
         WHERE relevecompteur_id = ? 
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
          montantPayer: row['montant_total_ttc'],
          statut: row['statut'],
        );

        return {'factures': factures};

      } else {
        final emptyFacture = FactureModel(
          id: 0,
          relevecompteurId: 0,
          numFacture: '',
          numCompteur: 0,
          dateFacture: '',
          totalConsoHT: 0,
          tarifM3: 0.0,
          avoirAvant: 0.0,
          avoirUtilise: 0.0,
          restantPrecedant: 0.0,
          montantTotalTTC: 0.0,
          montantPayer: 0.0,
          statut: 'Pas trouvé.',
        );

        return {'factures': emptyFacture};
      }

    } catch (e) {
      throw Exception("Failed to get facture data by ID from local database: $e");
    }
  }

  Future<void> savePayementFactureLocal(int idFacture, double mountant) async {
    try {
      final Database db = await _niaDatabases.database;
      // Vérifier si la facture existe déjà dans la base de données
      final existingFacture = await db.query(
        'facture',
        where: 'id = ?',
        whereArgs: [idFacture],
      );
      if (existingFacture.isNotEmpty) {
        await db.update(
          'facture',
          {
            'statut': 'Payé',
            // Ajoutez d'autres champs à mettre à jour si nécessaire
          },
          where: 'id = ?',
          whereArgs: [idFacture],
        );
        final DateTime now = DateTime.now();
        int relevecompteurId = existingFacture.first['id'] as int;
        int relevecompteur = existingFacture.first['relevecompteur_id'] as int;

        await db.update(
          'facture_paiment',
          {
            'facture_id': idFacture,
            'relevecompteur_id': relevecompteur,
            'paiement': mountant,
            'date_paiement': DateFormat('yyyy-MM-dd').format(now).toString(),
            'statut': 1
            // Ajoutez d'autres champs si nécessaire
          },
          where: 'facture_id = ?',
          whereArgs: [idFacture],
        );
        await _updateNombreReleverEffectue(db);
        print('Facture mise à jour avec succès dans la base de données locale');
      } else {
        // La facture n'existe pas, traiter ce cas en conséquence
        print('Aucune facture trouvée dans la table avec l\'ID: $idFacture');
      }
      print('Insertion du paiement de la facture réussie.');
    } catch (e) {
      print('Erreur lors de l\'enregistrement de la facture dans la base de données locale: $e');
      throw Exception('Erreur lors de l\'enregistrement de la facture dans la base de données locale: $e');
    }
  }

  Future<void> _updateNombreReleverEffectue(Database db) async {
    try {
      // Récupérer le nombre total de missions avec le statut 1 ou 0
      final factureCount = Sqflite.firstIntValue(await db.rawQuery('''
        SELECT COUNT(*) FROM facture WHERE statut IN ('Payé')
      '''));
      print("FactureCount $factureCount");
      // Mettre à jour le nombre de relevés effectués dans la table "acceuil"
      await db.rawUpdate('''
      UPDATE acceuil SET nombre_total_facture_payer = ?
    ''', [factureCount]);
    } catch (e) {
      throw Exception('Failed to update nombre_relever_effectuer: $e');
    }
  }

  Future<List<FacturePaymentModel>> getAllPayments() async {
    try {
      final Database db = await _niaDatabases.database;
      List<Map<String, dynamic>> rows = await db.query('facture_paiment');
      List<FacturePaymentModel> payments = [];
      for (var row in rows) {
        final payment = FacturePaymentModel(
          id: row['id'],
          factureId: row['facture_id'],
          relevecompteurId: row['relevecompteur_id'],
          paiement: row['paiement'],
          datePaiement: row['date_paiement'],
          statut: row['statut'],
        );
        payments.add(payment);
      }
      return payments;
    } catch (e) {
      throw Exception("Failed to get all payments from local database: $e");
    }
  }


}