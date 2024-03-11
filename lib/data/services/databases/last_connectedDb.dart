import 'package:sqflite/sqflite.dart';

class last_connected_db  {
  Future<void> createTable(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS last_Connected (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          id_utilisateur INTEGER,
          is_connected INTEGER
        );
      ''');

    } catch (e) {
      throw Exception("Failed to create last_Connected table: $e");
    }
  }
}