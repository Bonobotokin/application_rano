
import 'package:application_rano/data/models/anomalie_model.dart';
import 'package:application_rano/data/models/client_model.dart';
import 'package:application_rano/data/models/compteur_model.dart';
import 'package:application_rano/data/models/contrat_model.dart';
import 'package:application_rano/data/models/facture_model.dart';
import 'package:application_rano/data/models/home_model.dart';
import 'package:application_rano/data/models/last_connected_model.dart';
import 'package:application_rano/data/models/missions_model.dart';
import 'package:application_rano/data/models/releves_model.dart';
import 'package:application_rano/data/models/user.dart';
import 'package:application_rano/data/services/databases/nia_databases.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class SaveDataRepositoryLocale {

  Future<void> saveUserToLocalDatabase(User user) async {
    try {
      final Database db = await NiADatabases().database;
      await db.transaction((txn) async {
        final bool userExists =
        await isUserExists(txn, user.id_utilisateur ?? 0);
        if (userExists) {
          await updateUserInDatabase(txn, user);
          print('Données utilisateur mises à jour avec succès dans la base de données locale.');
        } else {
          await addUserToDatabase(txn, user);
          print('Données utilisateur enregistrées avec succès dans la base de données locale.');
        }
        await saveLastConnectedToDatabase(txn, user);
      });
    } catch (error) {
      throw Exception("Failed to save user to local database: $error");
    }
  }

  Future<void> saveInstanceAuthentification(User user) async {
    try {
      final Database db = await NiADatabases().database;
      await db.transaction((txn) async {
        final bool userExists = await isUserExists(txn, user.id_utilisateur ?? 0);
        if (userExists) {
          await saveLastConnectedToDatabase(txn, user);
          print('User Authentificaiotn instace connection enregistrer avec succès dans la base de données locale.');
        }
      });
    } catch (error) {
      throw Exception("Failed to save user to local database: $error");
    }
  }

  Future<bool> isUserExists(Transaction txn, int idUtilisateur) async {
    final List<Map<String, dynamic>> existingUserRows = await txn.query(
      'users',
      where: 'id_utilisateur = ?',
      whereArgs: [idUtilisateur],
    );
    return existingUserRows.isNotEmpty;
  }

  Future<void> addUserToDatabase(Transaction txn, User user) async {
    await txn.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateUserInDatabase(Transaction txn, User user) async {
    await txn.update(
      'users',
      user.toMap(),
      where: 'id_utilisateur = ?',
      whereArgs: [user.id_utilisateur],
    );
  }

  Future<void> saveLastConnectedToDatabase(Transaction txn, User user) async {
    final LastConnectedModel lastConnectedModel = LastConnectedModel(
      id: user.id_utilisateur ?? 0,
      id_utilisateur: user.id_utilisateur ?? 0,
      is_connected: 1,
    );

    await txn.insert(
      'last_Connected',
      lastConnectedModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print('Données de connexion enregistrées avec succès dans la base de données locale.');
  }

  Future<void> saveHomeDataToLocalDatabase(HomeModel homeModel) async {
    try {
      final db = await NiADatabases().database;
      await db.transaction((txn) async {
        final List<Map<String, dynamic>> existingRows = await txn.query(
          'acceuil',
          where: 'totale_anomalie = ? AND realise = ? AND nombre_total_compteur = ? AND nombre_relever_effectuer = ?',
          whereArgs: [
            homeModel.totaleAnomalie,
            homeModel.realise,
            homeModel.nombreTotalCompteur,
            homeModel.nombreReleverEffectuer,
          ],
        );

        if (existingRows.isNotEmpty) {
          print('Les données d\'accueil existent déjà dans la base de données locale.');

          // Si les données existent déjà, effectuer une mise à jour
          await txn.update(
            'acceuil',
            homeModel.toMap(),
            where: 'totale_anomalie = ? AND realise = ? AND nombre_total_compteur = ? AND nombre_relever_effectuer = ?',
            whereArgs: [
              homeModel.totaleAnomalie,
              homeModel.realise,
              homeModel.nombreTotalCompteur,
              homeModel.nombreReleverEffectuer,
            ],
          );

          // Affichage de l'aperçu pour les données d'accueil mises à jour
          print('Données d\'accueil mises à jour avec succès dans la base de données locale: $homeModel');
          return;
        }

        // Si les données n'existent pas, effectuer une insertion
        await txn.insert(
          'acceuil',
          homeModel.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Affichage de l'aperçu pour les données d'accueil enregistrées
        print('Données d\'accueil enregistrées avec succès dans la base de données locale: $homeModel');
      });
    } catch (error) {
      throw Exception("Failed to save home data to local database: $error");
    }
  }



  Future<void> saveMissionsDataToLocalDatabase(Transaction txn, List<MissionModel> missions) async {
    try {
      for (final mission in missions) {
        final List<Map<String, dynamic>> existingRows = await txn.query(
          'missions',
          where: 'nom_client = ? AND prenom_client = ? AND adresse_client = ? AND num_compteur = ? ',
          whereArgs: [
            mission.nomClient,
            mission.prenomClient,
            mission.adresseClient,
            mission.numCompteur
            // mission.consoDernierReleve,
            // mission.volumeDernierReleve,
            // mission.dateReleve,
            // mission.statut,
          ],
        );

        if (existingRows.isNotEmpty) {
          print('Les données de mission existent déjà dans la base de données locale.');

          // Update des données de mission
          await txn.update(
            'missions',
            mission.toJson(),
            where: 'nom_client = ? AND prenom_client = ? AND adresse_client = ? AND num_compteur = ? ',
            whereArgs: [
              mission.nomClient,
              mission.prenomClient,
              mission.adresseClient,
              mission.numCompteur
              // mission.consoDernierReleve,
              // mission.volumeDernierReleve,
              // mission.dateReleve,
              // mission.statut,
            ],
          );

          // Affichage de l'aperçu pour chaque mission mise à jour
          print('Données de mission mises à jour avec succès dans la base de données locale : $mission');

          continue;
        }

        // Si aucune donnée de mission existante, alors effectuer une insertion
        await txn.insert(
          'missions',
          mission.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Affichage de l'aperçu pour chaque mission enregistrée
        print('Données de mission enregistrées avec succès dans la base de données locale : $mission');
      }
    } catch (error) {
      throw Exception("Failed to save missions data to local database: $error");
    }
  }



  Future<void> saveCompteurDetailsRelever(CompteurModel compteurModel) async {
    try {
      final db = await NiADatabases().database;
      final List<Map<String, dynamic>> existingRows = await db.query(
        'compteur',
        where: 'id = ?',
        whereArgs: [compteurModel.id],
      );
      if (existingRows.isNotEmpty) {
        print('Les données de compteur existent déjà dans la base de données locale.');
        return;
      }

      await db.insert(
        'compteur',
        compteurModel.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Affichage de l'aperçu pour le compteur enregistré
      print('Données du compteur enregistrées avec succès dans la base de données locale : $compteurModel');
    } catch (error) {
      throw Exception("Failed to save compteur data to local database: $error");
    }
  }


  Future<void> saveContraDetailsRelever(ContratModel contratModel) async {
    try {
      final db = await NiADatabases().database;
      final List<Map<String, dynamic>> existingRows = await db.query(
        'contrat',
        where: 'id = ?',
        whereArgs: [contratModel.id],
      );
      if (existingRows.isNotEmpty) {
        print('Les données de contrat existent déjà dans la base de données locale.');
        return;
      }
      await db.insert(
        'contrat',
        contratModel.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Affichage de l'aperçu pour le contrat enregistré
      print('Données du contrat enregistrées avec succès dans la base de données locale : $contratModel');
    } catch (error) {
      throw Exception("Failed to save contrat data to local database: $error");
    }
  }


  Future<void> saveClientDetailsRelever(ClientModel clientModel) async {
    try {
      final db = await NiADatabases().database;

      // Vérifier si les données du client existent déjà localement
      final List<Map<String, dynamic>> existingRows = await db.query(
        'client',
        where: 'nom = ? AND prenom = ? AND adresse = ? AND commune = ? AND region = ? AND telephone_1 = ? AND telephone_2 = ? AND actif = ?',
        whereArgs: [
          clientModel.nom,
          clientModel.prenom,
          clientModel.adresse,
          clientModel.commune,
          clientModel.region,
          clientModel.telephone_1,
          clientModel.telephone_2,
          clientModel.actif,
        ],
      );

      if (existingRows.isNotEmpty) {
        print('Les données de client existent déjà dans la base de données locale.');
        return;
      }

      // Insérer les données du client dans la base de données locale
      await db.insert(
        'client',
        clientModel.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('Données du client enregistrées avec succès dans la base de données locale.');

      // Vérifier si les données du client ont été correctement enregistrées
      final List<Map<String, dynamic>> insertedRows = await db.query(
        'client',
        where: 'nom = ? AND prenom = ? AND adresse = ? AND commune = ? AND region = ? AND telephone_1 = ? AND telephone_2 = ? AND actif = ?',
        whereArgs: [
          clientModel.nom,
          clientModel.prenom,
          clientModel.adresse,
          clientModel.commune,
          clientModel.region,
          clientModel.telephone_1,
          clientModel.telephone_2,
          clientModel.actif,
        ],
      );

      if (insertedRows.isEmpty) {
        print('Erreur : les données du client n\'ont pas été enregistrées correctement localement.');
      } else {
        print('Vérification réussie : les données du client ont été correctement enregistrées localement.');
        print('Données insérées : $insertedRows');
      }
    } catch (error) {
      throw Exception("Failed to save client data to local database: $error");
    }
  }


  Future<void> saveReleverDetailsRelever(List<RelevesModel> relevesModels) async {
    try {
      final db = await NiADatabases().database;
      for (final releve in relevesModels) {
        final List<Map<String, dynamic>> existingRows = await db.query(
          'releves',
          where: 'id_releve = ? AND compteur_id = ? AND contrat_id = ? AND client_id = ? AND date_releve = ? AND volume = ? AND conso = ? AND etatFacture = ?',
          whereArgs: [
            releve.idReleve,
            releve.compteurId,
            releve.contratId,
            releve.clientId,
            releve.dateReleve,
            releve.volume,
            releve.conso,
            releve.etatFacture
          ],
        );

        if (existingRows.isNotEmpty) {
          print('Les données de relevé existent déjà dans la base de données locale.');
          continue;
        }

        await db.insert(
          'releves',
          releve.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        // Affichage de l'aperçu pour le relevé enregistré
        print('Données de relevé enregistrées avec succès dans la base de données locale : $releve');
      }

      final List<Map<String, dynamic>> savedRows = await db.query('releves');
      print('Données enregistrées : $savedRows');
    } catch (error) {
      throw Exception("Failed to save releves data to local database: $error");
    }
  }


  Future<void> saveFactureData(FactureModel factureModel) async {
    try {
      final db = await NiADatabases().database;

      // Vérifiez d'abord si une facture avec les mêmes données existe déjà
      final List<Map<String, dynamic>> existingRows = await db.query(
        'facture',
        where: 'relevecompteur_id = ? AND num_facture = ? AND num_compteur = ? AND date_facture = ? AND total_conso_ht = ? AND tarif_m3 = ? AND avoir_avant = ? AND avoir_utilise = ? AND restant_precedant = ? AND montant_total_ttc = ? AND statut = ?',
        whereArgs: [
          factureModel.relevecompteurId,
          factureModel.numFacture,
          factureModel.numCompteur,
          factureModel.dateFacture,
          factureModel.totalConsoHT,
          factureModel.tarifM3,
          factureModel.avoirAvant,
          factureModel.avoirUtilise,
          factureModel.restantPrecedant,
          factureModel.montantTotalTTC,
          factureModel.statut
        ],
      );

      if (existingRows.isNotEmpty) {
        print('Les données de facture existent déjà dans la base de données locale.');
        return;
      } else {
        // Vérifiez si le montant total TTC de la facture est différent de 0.0 ou 0
        if (factureModel.montantTotalTTC != 0.0 || factureModel.montantTotalTTC != 0) {
          final factureId = await db.insert(
            'facture',
            factureModel.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          final DateTime now = DateTime.now();
          // Vérifiez également le statut de la facture
          final statutPaiement = factureModel.statut == "Payé" ? '1' : 'null';

          await db.insert(
            'facture_paiment',
            {
              'facture_id': factureId,
              'relevecompteur_id': factureModel.relevecompteurId ?? 0,
              'paiement': factureModel.montantPayer.toInt(), // Convertir en entier
              'date_paiement': DateFormat('yyyy-MM-dd').format(now),
              'statut': statutPaiement,
              // Ajoutez d'autres champs si nécessaire
            },
          );
        } else {
          print('Le montant total TTC de la facture est 0, ne pas enregistrer dans la base de données');
        }

        // Affichage de l'aperçu pour la facture enregistrée
        print('Données de facture enregistrées avec succès dans la base de données locale : $factureModel');
      }
    } catch (error) {
      throw Exception("Failed to save facture data to local database: $error");
    }
  }


  Future<void> saveAnomalieData(List<AnomalieModel> anomalie) async {
    try {
      print(anomalie);
      final db = await NiADatabases().database;
      for (final anomalies in anomalie) {
        final List<Map<String, dynamic>> existingRows = await db.query(
          'anomalie',
          where: 'id = ? AND id_mc = ? AND type_mc = ? AND date_declaration = ? AND longitude_mc = ? AND latitude_mc = ? AND description_mc = ? AND client_declare = ? AND cp_commune = ? AND commune = ? AND status = ?',
          whereArgs: [
            anomalies.id,
            anomalies.idMc,
            anomalies.typeMc,
            anomalies.dateDeclaration,
            anomalies.longitudeMc,
            anomalies.latitudeMc,
            anomalies.descriptionMc,
            anomalies.clientDeclare,
            anomalies.cpCommune,
            anomalies.commune,
            anomalies.status
          ],
        );

        if (existingRows.isNotEmpty) {
          print('Les données d\'anomalie existent déjà dans la base de données locale.');

          return;
        } else {
          await db.insert(
            'anomalie',
            anomalies.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          // Affichage de l'aperçu pour l'anomalie enregistrée
          print('Données d\'Anomalie enregistrées avec succès dans la base de données locale : $anomalies');
        }
      }
    } catch (e) {
      throw Exception("Échec de l'enregistrement des données d'anomalie dans la base de données locale : $e");
    }
  }


}
