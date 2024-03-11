import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:application_rano/data/models/user.dart';
import 'package:application_rano/data/services/databases/nia_databases.dart';
import 'package:sqflite/sqflite.dart';

class UserRepository {
  Future<void> insertUsers(List<User> users) async {
    try {
      final db = await NiADatabases().database;
      await db.transaction((txn) async {
        for (var utilisateur in users) {
          // Récupérer l'ID de l'utilisateur à partir de l'objet User
          int? id_utilisateur = utilisateur.id_utilisateur;
          // Créer la carte des données à insérer, y compris l'ID de l'utilisateur si disponible
          Map<String, dynamic> userData = utilisateur.toMapExcludingId();
          if (id_utilisateur != null) {
            userData['id_utilisateur'] = id_utilisateur;
          }
          // Insérer les données dans la base de données
          await txn.insert(
            'users',
            userData,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    } catch (error) {
      throw Exception("Erreur lors de l'insertion des utilisateurs: $error");
    }
  }

  Future<void> insertUserConnected(User user) async {
    try {
      final db = await NiADatabases().database;
      await db.insert(
        'last_Connected',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (error) {
      throw Exception("Failed to save user to local database: $error");
    }
  }

  // Méthode pour récupérer tous les utilisateurs de la base de données locale
  Future<List<User>> getUsers() async {
    try {
      final usersDb = NiADatabases();
      final db = await usersDb.database;
      final List<Map<String, dynamic>> maps = await db.query('users');
      // Créer une liste pour stocker tous les utilisateurs
      List<User> users = [];
      // Parcourir les données récupérées de la base de données et les transformer en objets User
      for (var map in maps) {
        users.add(User.fromMap(map));
      }
      return users;
    } catch (error) {
      throw Exception(
          "Erreur lors de la récupération des utilisateurs depuis la base de données: $error");
    }
  }

  // Fonction pour mettre à jour ou insérer les utilisateurs dans la base de données locale
  Future<void> updateOrInsertUsers(
      List<User> apiUsers, List<User> localUsers) async {
    try {
      final usersDb = NiADatabases();
      final db = await usersDb.database;

      // Parcourir les utilisateurs de l'API
      for (var apiUser in apiUsers) {
        // Vérifier si l'utilisateur de l'API existe déjà localement
        bool userExistsLocally = localUsers
            .any((user) => user.id_utilisateur == apiUser.id_utilisateur);

        if (userExistsLocally) {
          // Mettre à jour l'utilisateur existant
          await db.update(
            'users',
            apiUser.toMap(),
            where: 'id = ?',
            whereArgs: [apiUser.id_utilisateur],
          );
        } else {
          // Insérer le nouvel utilisateur
          await db.insert('users', apiUser.toMap());
        }
      }
    } catch (error) {
      throw Exception(
          "Erreur lors de la mise à jour ou de l'insertion des utilisateurs: $error");
    }
  }
}
