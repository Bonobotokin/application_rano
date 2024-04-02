import 'package:sqflite/sqflite.dart';
class anomalie_db {
  Future<void> createTable(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE anomalie (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          id_mc INTEGER,
          type_mc TEXT NULL,
          date_declaration TEXT NULL,
          longitude_mc TEXT NULL,
          latitude_mc TEXT NULL,
          description_mc TEXT NULL,
          client_declare TEXT NULL,
          cp_commune TEXT NULL,
          commune TEXT NULL,
          status INTEGER
        );
      ''');
    } catch (e) {
      throw Exception("Failed to create anomalie table: $e");
    }
  }
}