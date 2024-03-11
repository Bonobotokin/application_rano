import 'package:sqflite/sqflite.dart';
class acceuil_db {
  Future<void> createTable(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE acceuil (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          totale_anomalie INTEGER,
          realise INTEGER,
          nombre_total_compteur INTEGER,
          nombre_relever_effectuer INTEGER
        );
      ''');
    } catch (e) {
      throw Exception("Failed to create accueil table: $e");
    }
  }
}