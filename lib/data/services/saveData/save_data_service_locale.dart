
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
import 'package:application_rano/data/repositories/relever_repository.dart';
import 'package:application_rano/data/services/databases/nia_databases.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import '../../repositories/local/missions_repository_locale.dart';

class SaveDataRepositoryLocale {

  final MissionsRepositoryLocale _missionsRepositoryLocale;
  final ReleverRepository _releverRepository;
  SaveDataRepositoryLocale() : _missionsRepositoryLocale = MissionsRepositoryLocale(), _releverRepository = ReleverRepository();
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
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM acceuil'));

      if (count == 0) {
        // Si la table est vide, insérer une nouvelle ligne avec les données distantes
        await db.insert(
          'acceuil',
          homeModel.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        print('Nouvelle ligne d\'accueil insérée avec succès dans la base de données locale: $homeModel');
      } else {
        // Si la table n'est pas vide, mettre à jour la seule ligne existante avec les nouvelles données
        await db.update(
          'acceuil',
          homeModel.toMap(),
        );
        print('Données d\'accueil mises à jour avec succès dans la base de données locale: $homeModel');
      }
    } catch (error) {
      throw Exception("Failed to save home data to local database: $error");
    }
  }


  Future<void> saveMissionsDataToLocalDatabase(List<MissionModel> missionsDataOnline) async {
    final Database db = await NiADatabases().database;
    final localMissions = await MissionsRepositoryLocale().getMissionsDataFromLocalDatabase();

    await db.transaction((txn) async {
      for (final missionOnline in missionsDataOnline) {
        final existingMission = localMissions.firstWhere(
              (mission) => mission.numCompteur == missionOnline.numCompteur,
          orElse: () => MissionModel(), // Utiliser null pour indiquer qu'aucune mission n'existe
        );
        print("verrifie missionExiste ${existingMission}");
        try {
          if (existingMission.numCompteur != null) {

            // Si existingMission n'est pas null, vous pouvez accéder à ses propriétés en toute sécurité
            print('Données existantes de mission : $existingMission');
            final updatedata = await _updateMission(txn, missionOnline);
            print('Données de mission mises à jour avec succès dans la base de données locale : $missionOnline');
          } else {
            // Si existingMission est null, vous devez gérer ce cas
            print('Aucune donnée existante de mission trouvée.');
            final inserte = await _insertMission(txn, missionOnline);
            print('Données de mission enregistrées avec succès dans la base de données locale : $missionOnline');
          }

        } catch (e) {
          print('Erreur lors de la mise à jour ou de l\'insertion des données de mission : $e');
        }
      }
    });
  }

  Future<void> _updateMission(Transaction txn, MissionModel mission) async {
    try {
      await txn.update(
        'missions',
        mission.toJson(),
        where: 'num_compteur = ? AND date_releve = ?',
        whereArgs: [
          mission.numCompteur,
          mission.dateReleve, // Ajoutez la date de relevé dans les arguments
        ],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Mission mise à jour : ${mission.toJson()}');
    } catch (e) {
      print('Erreur lors de la mise à jour de la mission : $e');
      rethrow; // Relancer l'exception pour gérer l'erreur au niveau supérieur
    }
  }

  Future<void> _insertMission(Transaction txn, MissionModel mission) async {
    try {
      await txn.insert(
        'missions',
        mission.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Mission insérée : ${mission.toJson()}');
    } catch (e) {
      print('Erreur lors de l\'insertion de la mission : $e');
      rethrow; // Relancer l'exception pour gérer l'erreur au niveau supérieur
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


  // Future<void> saveReleverDetailsRelever(List<RelevesModel> relevesModels) async {
  //   try {
  //     final db = await NiADatabases().database;
  //     for (final releve in relevesModels) {
  //       print("fffffffffffffffffff $releve");
  //
  //       String modifiedImageCompteur = releve.imageCompteur;
  //
  //       if (releve.imageCompteur.isNotEmpty && releve.imageCompteur.startsWith("/media/compteurs/${releve.compteurId}/")) {
  //         modifiedImageCompteur = releve.imageCompteur.replaceAll("/media/compteurs/${releve.compteurId}/", "/data/user/0/com.example.application_rano/app_flutter/assets/images/");
  //       }
  //
  //       final List<Map<String, dynamic>> existingRows = await db.query(
  //         'releves',
  //         where: 'id_releve = ? AND compteur_id = ? AND contrat_id = ? AND client_id = ? AND date_releve = ? AND volume = ? AND conso = ? AND etatFacture = ? AND image_compteur = ? ',
  //         whereArgs: [
  //           releve.idReleve,
  //           releve.compteurId,
  //           releve.contratId,
  //           releve.clientId,
  //           releve.dateReleve,
  //           releve.volume,
  //           releve.conso,
  //           releve.etatFacture,
  //           releve.imageCompteur // Utilisez l'image originale ici, car c'est ce qui est stocké dans la base de données
  //         ],
  //       );
  //
  //       if (existingRows.isNotEmpty) {
  //         print('Les données de relevé existent déjà dans la base de données locale.');
  //         // Mise à jour des données
  //         await db.update(
  //           'releves',
  //           releve.toMap()..['image_compteur'] = modifiedImageCompteur, // Mettre à jour l'image_compteur avec la valeur modifiée
  //           where: 'id_releve = ? AND compteur_id = ? AND contrat_id = ? AND client_id = ? AND date_releve = ? AND volume = ? AND conso = ? AND etatFacture = ? AND image_compteur = ? ',
  //           whereArgs: [
  //             releve.idReleve,
  //             releve.compteurId,
  //             releve.contratId,
  //             releve.clientId,
  //             releve.dateReleve,
  //             releve.volume,
  //             releve.conso,
  //             releve.etatFacture,
  //             releve.imageCompteur // Utilisez l'image originale ici, car c'est ce qui est stocké dans la base de données
  //           ],
  //         );
  //         print('Données de relevé mises à jour avec succès dans la base de données locale : $releve');
  //         continue;
  //       }
  //
  //       await db.insert(
  //         'releves',
  //         {
  //           ...releve.toMap(), // Ajouter les valeurs existantes du modèle
  //           'id': releve.id,
  //           'id_releve': releve.idReleve,
  //           'compteur_id': releve.compteurId,
  //           'contrat_id': releve.contratId,
  //           'client_id': releve.clientId,
  //           'date_releve': releve.dateReleve,
  //           'volume': releve.volume,
  //           'conso': releve.conso,
  //           'etatFacture':  releve.etatFacture,
  //           'image_compteur': modifiedImageCompteur, // Ajouter la nouvelle valeur de l'image_compteur
  //         },
  //         conflictAlgorithm: ConflictAlgorithm.replace,
  //       );
  //       print('Données de relevé enregistrées avec succès dans la base de données locale : $releve');
  //     }
  //
  //     final List<Map<String, dynamic>> savedRows = await db.query('releves');
  //     print('Données enregistrées : $savedRows');
  //   } catch (error) {
  //     throw Exception("Failed to save releves data to local database: $error");
  //   }
  // }



  Future<void> saveReleverDetailsRelever(List<RelevesModel> releverDataOnlines) async {
    final Database db = await NiADatabases().database;

    print("11111111111111111 ");
    final List<Map<String, dynamic>> localRelever = await ReleverRepository().getAllReleves(db);

    print("localRelever ${localRelever}");
    // Vérifier si les données locales existent
    if (localRelever == null || localRelever.isEmpty) {
      // Les données locales sont vides, procédez à la synchronisation
      print("Les données locales de relevé sont vides. Effectuer la synchronisation...");

      await db.transaction((txn) async {
        for (final releverDataOnline in releverDataOnlines) {
          try {
            final existingRelever = localRelever.firstWhere(
                  (relever) => relever['compteur_id'] == releverDataOnline.compteurId,
              orElse: () => <String, dynamic>{}, // Retourne une map vide par défaut si aucun relevé n'est trouvé
            );

            print("vérifie relevéExiste ${existingRelever}");

            // Modifier l'image du compteur si nécessaire
            String modifiedImageCompteur = releverDataOnline.imageCompteur;
            if (releverDataOnline.imageCompteur.isNotEmpty && releverDataOnline.imageCompteur.startsWith("/media/compteurs/${releverDataOnline.compteurId}/")) {
              modifiedImageCompteur = releverDataOnline.imageCompteur.replaceAll("/media/compteurs/${releverDataOnline.compteurId}/", "/data/user/0/com.example.application_rano/app_flutter/assets/images/");
            }

            if (existingRelever != null && existingRelever.isNotEmpty) {
              // Si le relevé existe déjà, mettez à jour les données
              print('Données existantes de relevé : $existingRelever');
              await _updateRelever(txn, releverDataOnline, modifiedImageCompteur);
              print('Données de relevé mises à jour avec succès dans la base de données locale : $releverDataOnline');
            } else {
              // Si le relevé n'existe pas, insérez de nouvelles données
              print('Aucune donnée existante de relevé trouvée ou relevé vide.');
              await _insertRelever(txn, releverDataOnline, modifiedImageCompteur);
              print('Données de relevé enregistrées avec succès dans la base de données locale : $releverDataOnline');
            }

          } catch (e) {
            print('Erreur lors de la mise à jour ou de l\'insertion des données de relevé : $e');
          }
        }
      });

      print("Synchronisation terminée.");
    } else {
      // Les données locales existent, aucune synchronisation nécessaire
      print("Les données locales de relevé existent. Aucune synchronisation nécessaire.");
    }
  }



  Future<void> _updateRelever(Transaction txn, RelevesModel relever, String modifiedImageCompteur) async {
    try {
      await txn.update(
        'releves',
        {
          ...relever.toMap(),
          'image_compteur': modifiedImageCompteur,
        },
        where: 'id_releve = ? AND compteur_id = ? AND contrat_id = ? AND client_id = ? AND date_releve = ? AND volume = ? AND conso = ? AND etatFacture = ? AND image_compteur = ?',
        whereArgs: [
          relever.idReleve,
          relever.compteurId,
          relever.contratId,
          relever.clientId,
          relever.dateReleve,
          relever.volume,
          relever.conso,
          relever.etatFacture,
          relever.imageCompteur,
        ],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Relevé mis à jour : ${relever.toJson()}');
    } catch (e) {
      print('Erreur lors de la mise à jour du relevé : $e');
      rethrow;
    }
  }

  Future<void> _insertRelever(Transaction txn, RelevesModel relever, String modifiedImageCompteur) async {
    try {
      await txn.insert(
        'releves',
        {
          ...relever.toMap(),
          'image_compteur': modifiedImageCompteur,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Relevé inséré : ${relever.toJson()}');
    } catch (e) {
      print('Erreur lors de l\'insertion du relevé : $e');
      rethrow;
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

        final existingFacture = existingRows[0];
        final existingFactureId = existingFacture['id'];

        // Vérifiez les attributs et mettez à jour si nécessaire
        if (factureModel.montantTotalTTC != existingFacture['montant_total_ttc'] || factureModel.statut != existingFacture['statut']) {
          await db.update(
            'facture',
            {
              'montant_total_ttc': factureModel.montantTotalTTC,
              'statut': factureModel.statut,
            },
            where: 'id = ?',
            whereArgs: [existingFactureId],
          );

          print('Les données de facture existante ont été mises à jour.');
          if (factureModel.statut == "Payé") {
            final factureId = existingRows[0]['id'];

            await db.update(
              'facture_paiment',
              {'statut': 'Payé'},
              where: 'facture_id = ?',
              whereArgs: [factureId],
            );
          }
        } else {
          print('Les données de facture existante sont déjà à jour.');
        }

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
        print('Données de facture enregistrées avec succès dans la base de données locale : $factureModel');
      }
    } catch (error) {
      throw Exception("Failed to save facture data to local database: $error");
    }
  }

  Future<void> saveAnomalieData(List<AnomalieModel> anomalies) async {
    try {
      final db = await NiADatabases().database;
      for (final anomalie in anomalies) {
        // Modification du chemin de l'image de compteur
        String modifiedImageCompteur = anomalie.photoAnomalie1 ?? '';
        if (modifiedImageCompteur.isNotEmpty && modifiedImageCompteur.startsWith("/mmedia/mc/")) {
          modifiedImageCompteur = modifiedImageCompteur.replaceAll("/media/mc/", "/data/user/0/com.example.application_rano/app_flutter/assets/images/");
        }

        // Modification des chemins des images d'anomalie
        String modifiedImageAnomalie1 = modifyImagePath(anomalie.photoAnomalie1 ?? '', anomalie.idMc ?? 0);
        String modifiedImageAnomalie2 = modifyImagePath(anomalie.photoAnomalie2 ?? '', anomalie.idMc ?? 0);
        String modifiedImageAnomalie3 = modifyImagePath(anomalie.photoAnomalie3 ?? '', anomalie.idMc ?? 0);
        String modifiedImageAnomalie4 = modifyImagePath(anomalie.photoAnomalie4 ?? '', anomalie.idMc ?? 0);
        String modifiedImageAnomalie5 = modifyImagePath(anomalie.photoAnomalie5 ?? '', anomalie.idMc ?? 0);

        // Vérification de l'existence de données d'anomalie dans la base de données locale
        final existingRows = await db.query(
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
            modifiedImageAnomalie1,
            modifiedImageAnomalie2,
            modifiedImageAnomalie3,
            modifiedImageAnomalie4,
            modifiedImageAnomalie5
          ],
        );

        if (existingRows.isEmpty) {
          print('Les données d\'anomalie n\'existent pas encore dans la base de données locale. Enregistrement...');
          // Insertion de nouvelles données d'anomalie dans la base de données
          await db.insert(
            'anomalie',
            {
              ...anomalie.toMap(),
              'id': anomalie.id,
              'id_mc': anomalie.idMc,
              'type_mc': anomalie.typeMc,
              'date_declaration': anomalie.dateDeclaration,
              'longitude_mc': anomalie.longitudeMc,
              'latitude_mc': anomalie.latitudeMc,
              'description_mc': anomalie.descriptionMc,
              'client_declare': anomalie.clientDeclare,
              'cp_commune': anomalie.cpCommune,
              'commune': anomalie.commune,
              'status': anomalie.status,
              'photo_anomalie_1': modifiedImageAnomalie1,
              'photo_anomalie_2': modifiedImageAnomalie2,
              'photo_anomalie_3': modifiedImageAnomalie3,
              'photo_anomalie_4': modifiedImageAnomalie4,
              'photo_anomalie_5': modifiedImageAnomalie5,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          print('Données d\'Anomalie enregistrées avec succès dans la base de données locale : $anomalie');
        } else {
          print('Les données d\'anomalie existent déjà dans la base de données locale.');
          // Mise à jour des données d'anomalie
          await db.update(
            'anomalie',
            {
              ...anomalie.toMap(),
              'photo_anomalie_1': modifiedImageAnomalie1,
              'photo_anomalie_2': modifiedImageAnomalie2,
              'photo_anomalie_3': modifiedImageAnomalie3,
              'photo_anomalie_4': modifiedImageAnomalie4,
              'photo_anomalie_5': modifiedImageAnomalie5,
            },
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
              modifiedImageAnomalie1,
              modifiedImageAnomalie2,
              modifiedImageAnomalie3,
              modifiedImageAnomalie4,
              modifiedImageAnomalie5
            ],
          );
          print('Données d\'anomalie mises à jour avec succès dans la base de données locale : $anomalie');
        }
      }
    } catch (e) {
      throw Exception("Échec de l'enregistrement des données d'anomalie dans la base de données locale : $e");
    }
  }


// Fonction pour modifier les chemins des images d'anomalie en fonction de l'identifiant idMc
  String modifyImagePath(String imagePath, int idMc) {
    if (imagePath.isNotEmpty && imagePath.startsWith("/media/mc/$idMc/")) {
      return imagePath.replaceAll("/media/mc/$idMc/", "/data/user/0/com.example.application_rano/app_flutter/assets/images/");
    }
    return imagePath;
  }


}