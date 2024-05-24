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
        final bool userExists = await isUserExists(txn, user.id_utilisateur ?? 0);
        if (userExists) {
          await updateUserInDatabase(txn, user);
          print('Données utilisateur mises à jour avec succès.');
        } else {
          await addUserToDatabase(txn, user);
          print('Données utilisateur enregistrées avec succès.');
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
          print('User Authentification instance connection saved.');
        }
      });
    } catch (error) {
      throw Exception("Failed to save user authentication to local database: $error");
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
      'last_connected',
      lastConnectedModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print('Données de connexion enregistrées avec succès.');
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
        if (await isMissionDataExists(txn, mission)) {
          await updateMissionData(txn, mission);
        } else {
          await addMissionData(txn, mission);
        }
      }
    } catch (error) {
      throw Exception("Failed to save missions data to local database: $error");
    }
  }
  Future<void> saveClientDetailsRelever(ClientModel clientModel) async {
    try {
      final db = await NiADatabases().database;
      await db.transaction((txn) async {
        if (await isClientDataExists(txn, clientModel)) {
          await updateClientData(txn, clientModel);
        } else {
          await addClientData(txn, clientModel);
        }
      });
    } catch (error) {
      throw Exception("Failed to save client data to local database: $error");
    }
  }

  Future<bool> isClientDataExists(Transaction txn, ClientModel clientModel) async {
    final List<Map<String, dynamic>> existingRows = await txn.query(
      'client',
      where: 'id = ?',
      whereArgs: [clientModel.id],
    );
    return existingRows.isNotEmpty;
  }

  Future<void> addClientData(Transaction txn, ClientModel clientModel) async {
    await txn.insert(
      'client',
      clientModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('Client data saved successfully: $clientModel');
  }

  Future<void> updateClientData(Transaction txn, ClientModel clientModel) async {
    await txn.update(
      'client',
      clientModel.toMap(),
      where: 'id = ?',
      whereArgs: [clientModel.id],
    );
    print('Client data updated successfully: $clientModel');
  }

  Future<bool> isMissionDataExists(Transaction txn, MissionModel mission) async {
    final List<Map<String, dynamic>> existingRows = await txn.query(
      'missions',
      where: 'nom_client = ? AND prenom_client = ? AND adresse_client = ? AND num_compteur = ?',
      whereArgs: [
        mission.nomClient,
        mission.prenomClient,
        mission.adresseClient,
        mission.numCompteur,
      ],
    );
    return existingRows.isNotEmpty;
  }

  Future<void> addMissionData(Transaction txn, MissionModel mission) async {
    await txn.insert(
      'missions',
      mission.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('Données de mission enregistrées avec succès: $mission');
  }

  Future<void> updateMissionData(Transaction txn, MissionModel mission) async {
    await txn.update(
      'missions',
      mission.toJson(),
      where: 'nom_client = ? AND prenom_client = ? AND adresse_client = ? AND num_compteur = ?',
      whereArgs: [
        mission.nomClient,
        mission.prenomClient,
        mission.adresseClient,
        mission.numCompteur,
      ],
    );
    print('Données de mission mises à jour avec succès: $mission');
  }

  Future<void> saveCompteurDetailsRelever(CompteurModel compteurModel) async {
    try {
      final db = await NiADatabases().database;
      if (await isCompteurDataExists(db, compteurModel)) {
        print('Les données de compteur existent déjà.');
        return;
      }
      await db.insert(
        'compteur',
        compteurModel.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Données du compteur enregistrées avec succès: $compteurModel');
    } catch (error) {
      throw Exception("Failed to save compteur data: $error");
    }
  }

  Future<bool> isCompteurDataExists(Database db, CompteurModel compteurModel) async {
    final List<Map<String, dynamic>> existingRows = await db.query(
      'compteur',
      where: 'id = ?',
      whereArgs: [compteurModel.id],
    );
    return existingRows.isNotEmpty;
  }

  Future<void> saveContraDetailsRelever(ContratModel contratModel) async {
    try {
      final db = await NiADatabases().database;
      if (await isContratDataExists(db, contratModel)) {
        print('Les données de contrat existent déjà.');
        return;
      }
      await db.insert(
        'contrat',
        contratModel.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Données du contrat enregistrées avec succès: $contratModel');
    } catch (error) {
      throw Exception("Failed to save contrat data: $error");
    }
  }

  Future<bool> isContratDataExists(Database db, ContratModel contratModel) async {
    final List<Map<String, dynamic>> existingRows = await db.query(
      'contrat',
      where: 'id = ?',
      whereArgs: [contratModel.id],
    );
    return existingRows.isNotEmpty;
  }

  Future<void> saveReleverDetailsRelever(List<RelevesModel> relevesModels) async {
    try {
      final db = await NiADatabases().database;
      await db.transaction((txn) async {
        for (final releve in relevesModels) {
          print("fffffffffffffffffff");
          // Manipulez le chemin d'accès à l'image ici
          String modifiedImageCompteur = releve.imageCompteur;
          if (releve.imageCompteur.isNotEmpty && releve.imageCompteur.startsWith("/media/compteurs/1234/")) {
            modifiedImageCompteur = releve.imageCompteur.replaceAll("/media/compteurs/1234/", "/data/user/0/com.example.application_rano/app_flutter/assets/images/");
          }

          final existingRows = await txn.query(
            'releves',
            where: 'id_releve = ?',
            whereArgs: [releve.idReleve],
          );

          if (existingRows.isNotEmpty) {
            print('Les données de relevé existent déjà dans la base de données locale.');
            // Mise à jour des données
            await txn.update(
              'releves',
              releve.toMap()..['image_compteur'] = modifiedImageCompteur,
              where: 'id_releve = ?',
              whereArgs: [releve.idReleve],
            );
            print('Données de relevé mises à jour avec succès dans la base de données locale : $releve');
          } else {
            await txn.insert(
              'releves',
              releve.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            print('Données de relevé enregistrées avec succès dans la base de données locale : $releve');
          }
        }
      });

      final savedRows = await db.query('releves');
      print('Données enregistrées : $savedRows');
    } catch (error) {
      throw Exception("Failed to save releves data to local database: $error");
    }
  }



  Future<void> saveFactureData(FactureModel factureModel) async {
    try {
      final db = await NiADatabases().database;
      await db.transaction((txn) async {
        if (await isFactureDataExists(txn, factureModel)) {
          await updateFactureData(txn, factureModel);
        } else {
          await addFactureData(txn, factureModel);
        }
      });
    } catch (error) {
      throw Exception("Failed to save facture data to local database: $error");
    }
  }

  Future<bool> isFactureDataExists(Transaction txn, FactureModel factureModel) async {
    final List<Map<String, dynamic>> existingRows = await txn.query(
      'facture',
      where: 'id = ?',
      whereArgs: [factureModel.id],
    );
    return existingRows.isNotEmpty;
  }

  Future<void> addFactureData(Transaction txn, FactureModel factureModel) async {
    await txn.insert(
      'facture',
      factureModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('Facture data saved successfully: $factureModel');
  }

  Future<void> updateFactureData(Transaction txn, FactureModel factureModel) async {
    await txn.update(
      'facture',
      factureModel.toMap(),
      where: 'id = ?',
      whereArgs: [factureModel.id],
    );
    print('Facture data updated successfully: $factureModel');
  }


  Future<void> saveAnomalieDataToLocalDatabase(List<AnomalieModel> anomalies) async {
    try {
      final db = await NiADatabases().database;
      await db.transaction((txn) async {
        for (final anomalie in anomalies) {
          final List<Map<String, dynamic>> existingRows = await txn.query(
            'anomalie',
            where: 'id_mc = ? AND type_mc = ? AND date_declaration = ? AND longitude_mc = ? AND latitude_mc = ? AND '
                'description_mc = ? AND client_declare = ? AND cp_commune = ? AND commune = ? AND status = ? AND '
                'photo_anomalie_1 = ? AND photo_anomalie_2 = ? AND photo_anomalie_3 = ? AND photo_anomalie_4 = ? AND photo_anomalie_5 = ? ',
            whereArgs: [
              anomalie.idMc,
              anomalie.typeMc,
              anomalie.dateDeclaration,
              anomalie.longitudeMc,
              anomalie.latitudeMc,
              anomalie.descriptionMc,
              anomalie.clientDeclare,
              anomalie.cpCommune,
              anomalie.commune,
              anomalie.status,
              anomalie.photoAnomalie1,
              anomalie.photoAnomalie2,
              anomalie.photoAnomalie3,
              anomalie.photoAnomalie4,
              anomalie.photoAnomalie5
            ],
          );

          if (existingRows.isNotEmpty) {
            print('Les données d\'anomalie existent déjà dans la base de données locale.');
            // Mise à jour des données
            await txn.update(
              'anomalie',
              anomalie.toMap(),
              where: 'id_mc = ? AND type_mc = ? AND date_declaration = ? AND longitude_mc = ? AND latitude_mc = ? AND '
                  'description_mc = ? AND client_declare = ? AND cp_commune = ? AND commune = ? AND status = ? AND '
                  'photo_anomalie_1 = ? AND photo_anomalie_2 = ? AND photo_anomalie_3 = ? AND photo_anomalie_4 = ? AND photo_anomalie_5 = ? ',
              whereArgs: [
                anomalie.idMc,
                anomalie.typeMc,
                anomalie.dateDeclaration,
                anomalie.longitudeMc,
                anomalie.latitudeMc,
                anomalie.descriptionMc,
                anomalie.clientDeclare,
                anomalie.cpCommune,
                anomalie.commune,
                anomalie.status,
                anomalie.photoAnomalie1,
                anomalie.photoAnomalie2,
                anomalie.photoAnomalie3,
                anomalie.photoAnomalie4,
                anomalie.photoAnomalie5
              ],
            );
            print('Données d\'anomalie mises à jour avec succès dans la base de données locale : $anomalie');
          } else {
            await txn.insert(
              'anomalie',
              anomalie.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            print('Données d\'Anomalie enregistrées avec succès dans la base de données locale : $anomalie');
          }
        }
      });
    } catch (e) {
      throw Exception("Échec de l'enregistrement des données d'anomalie dans la base de données locale : $e");
    }
  }

}
