import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:application_rano/data/models/user.dart';

class users_db {
  get database => null;

  Future<void> createTable(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
        id_utilisateur INTEGER PRIMARY KEY,
        nom_utilisateur TEXT,
        prenom_utilisateur TEXT, 
        num_utilisateur TEXT,
        password TEXT,
        cp_commune TEXT,
        role_id INTEGER,
        last_token TEXT
      );

      ''');
    } catch (e) {
      throw Exception("Failed to create users table: $e");
    }
  }

}
