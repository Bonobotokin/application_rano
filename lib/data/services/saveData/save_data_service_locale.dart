import 'dart:convert';

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
          return;
        }

        await txn.insert(
          'acceuil',
          homeModel.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        print('Données d\'accueil enregistrées avec succès dans la base de données locale.');
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
          where: 'nom_client = ? AND prenom_client = ? AND adresse_client = ? AND num_compteur = ? AND conso_dernier_releve = ? AND volume_dernier_releve = ? AND date_releve = ? AND statut = ?',
          whereArgs: [
            mission.nomClient,
            mission.prenomClient,
            mission.adresseClient,
            mission.numCompteur,
            mission.consoDernierReleve,
            mission.volumeDernierReleve,
            mission.dateReleve,
            mission.statut,
          ],
        );

        if (existingRows.isNotEmpty) {
          print('Les données de mission existent déjà dans la base de données locale.');
          continue;
        }

        await txn.insert(
          'missions',
          mission.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        print('Données de mission enregistrées avec succès dans la base de données locale.');
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

      print('Données du compteur enregistrées avec succès dans la base de données locale.');
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

      print('Données du contrat enregistrées avec succès dans la base de données locale.');
    } catch (error) {
      throw Exception("Failed to save contrat data to local database: $error");
    }
  }

  Future<void> saveClientDetailsRelever(ClientModel clientModel) async {
    try {
      final db = await NiADatabases().database;
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

      await db.insert(
        'client',
        clientModel.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('Données du client enregistrées avec succès dans la base de données locale.');
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
          where: 'compteur_id = ? AND contrat_id = ? AND client_id = ? AND date_releve = ? AND volume = ? AND conso = ?',
          whereArgs: [
            releve.compteurId,
            releve.contratId,
            releve.clientId,
            releve.dateReleve,
            releve.volume,
            releve.conso,
          ],
        );

        if (existingRows.isNotEmpty) {
          print('Les données de mission existent déjà dans la base de données locale.');
          continue;
        }

        await db.insert(
          'releves',
          releve.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        print('Données de mission enregistrées avec succès dans la base de données locale.');
      }

      final List<Map<String, dynamic>> savedRows = await db.query('releves');
      print('Données enregistrées : $savedRows');
    } catch (error) {
      throw Exception("Failed to save missions data to local database: $error");
    }
  }

  Future<void> saveFactureData(FactureModel factureModel) async {
    try {
      final db = await NiADatabases().database;
      final List<Map<String, dynamic>> existingRows = await db.query(
        'facture',
        where: 'relevecompteur_id = ? AND '
            'num_facture = ? AND '
            'num_compteur = ? AND '
            'date_facture = ? AND '
            'total_conso_ht = ? AND '
            'tarif_m3 = ? AND '
            'avoir_avant = ? AND '
            'avoir_utilise = ? AND '
            'restant_precedant = ? AND '
            'montant_total_ttc = ? AND '
            'statut = ?',
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
      }
      await db.insert(
        'facture',
        factureModel.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('Données du facture enregistrées avec succès dans la base de données locale : $factureModel');

    } catch (e) {
      throw Exception("Failed to save facture data to local database: $e");
    }
  }



// Future<void> saveFactureData(List<FactureModel> factureData) async {
  //   final db = await NiADatabases().database;
  //   await db.transaction((txn) async {
  //     for (final facture in factureData) {
  //       // Vérifier si la facture existe déjà localement
  //       final existingFacture = await _factureLocalRepository.getFactureById(facture.id);
  //       if (existingFacture == null) {
  //         // Si la facture n'existe pas déjà, l'insérer dans la base de données locale
  //         await _saveDataRepositoryLocale.saveFactureData(facture);
  //       } else {
  //         // Si la facture existe déjà, passer à la suivante
  //         print("Facture with ID ${facture.id} already exists locally. Skipping insertion.");
  //       }
  //     }
  //   });
  // }
}
