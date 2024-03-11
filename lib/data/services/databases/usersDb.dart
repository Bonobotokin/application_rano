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

  Future<User?> authenticate(String phoneNumber, String password) async {
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'num_utilisateur = ? AND password = ?',
      whereArgs: [phoneNumber, password],
    );

    if (result.isNotEmpty) {
      return User.fromMap(
          result.first); // Si l'utilisateur est trouvé, retournez-le
    } else {
      return null; // Si aucun utilisateur correspondant n'est trouvé, retournez null
    }
  }
}
