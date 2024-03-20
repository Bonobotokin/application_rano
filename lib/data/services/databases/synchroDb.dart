import 'package:sqflite/sqflite.dart';

class synchro_db {
  Future<void> createTable(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS synchro_status (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          mission_id INTEGER,
          status INTEGER,
          last_sync TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (mission_id) REFERENCES missions(id)
        );
      ''');
    } catch (e) {
      throw Exception("Failed to create sync_status table: $e");
    }
  }
}