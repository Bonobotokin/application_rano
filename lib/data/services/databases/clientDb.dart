import 'package:sqflite/sqflite.dart';

class client_db {
  Future<void> createTable(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS client (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nom TEXT,
          prenom TEXT NULL,
          adresse TEXT NULL,
          commune TEXT NULL,
          region TEXT NULL,
          telephone_1 TEXT NULL,
          telephone_2 TEXT NULL,
          actif INTEGER
          
        );
      ''');
    } catch (e) {
      throw Exception("Failed to create client table: $e");
    }
  }
}