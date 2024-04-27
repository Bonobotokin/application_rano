import 'package:sqflite/sqflite.dart';

class photo_anomalie_db {
  Future<void> createTable(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS photAnomalie (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          photo_anomalie_1 TEXT,
          photo_anomalie_2 TEXT,
          photo_anomalie_3 TEXT,
          photo_anomalie_4 TEXT,
          photo_anomalie_5 TEXT,
          main_courante_id INTEGER,
          FOREIGN KEY (main_courante_id) REFERENCES anomalie(id)
        );
      ''');
    } catch (e) {
      throw Exception("Failed to create client table: $e");
    }
  }
}