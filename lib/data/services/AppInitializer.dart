import 'package:application_rano/data/models/server_config.dart';
import 'package:application_rano/data/services/databases/nia_databases.dart';

class AppInitializer {
  static ServerConfig? _serverConfig;

  static ServerConfig? get serverConfig => _serverConfig;

  static Future<void> initialize() async {
    await _initDatabase();
    // print("Initialisation complète.");
  }

  static Future<void> _initDatabase() async {
    // print("Initialisation de la base de données...");
    // Initialise la base de données
    NiADatabases niaDatabases = NiADatabases();
    await niaDatabases.initDatabase(); // Appeler la méthode initDatabase()
    // print("Base de données initialisée.");
  }

}
