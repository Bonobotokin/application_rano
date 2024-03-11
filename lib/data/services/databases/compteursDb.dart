import 'package:sqflite/sqflite.dart';

class compteurs_db {
  Future<void> createTable(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS compteur (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          marque TEXT,
          modele TEXT
        );
      ''');
    } catch (e) {
      throw Exception("Failed to create compteur table: $e");
    }
  }
}