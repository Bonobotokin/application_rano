import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:application_rano/data/services/config/api_configue.dart';
import 'package:application_rano/blocs/server/server_event.dart';
import 'package:application_rano/data/services/databases/nia_databases.dart';

enum ServerStatus {
  connected,
  disconnected,
  error,
  loading,
  synchronizing,
  synchronizationSuccess,
  synchronizationError,
}

class ServerBloc extends Bloc<ServerEvent, ServerStatus> {
  final NiADatabases niADatabases;


  ServerBloc(this.niADatabases)
      : super(ServerStatus.disconnected) {
    on<CheckServerStatusEvent>(_onCheckServerStatus);
    // on<LoadingSynchronisation>(_onLoadingSynchronisation);
  }

  Future<void> _onCheckServerStatus(
    CheckServerStatusEvent event,
    Emitter<ServerStatus> emit,
  ) async {
    emit(ServerStatus.loading);
    final status = await _mapCheckServerStatusToState();
    emit(status);
    if (status == ServerStatus.connected) {
      // Déclencher la synchronisation si le serveur est connecté
      // add(LoadingSynchronisation());
    }
  }

  Future<ServerStatus> _mapCheckServerStatusToState() async {
    try {
      // Utilisation de la fonction determineBaseUrl() pour obtenir la base URL
      final baseUrl = await ApiConfig.determineBaseUrl();
      if (baseUrl.isNotEmpty) {
        var response = await http.get(Uri.parse('$baseUrl/serveurTest'));
        if (response.statusCode == 200) {
          return ServerStatus.connected;
        } else {
          // Gérer d'autres codes d'erreur si nécessaire
          debugPrint('Erreur de connexion au serveur: ${response.statusCode}');
          return ServerStatus.disconnected;
        }
      } else {
        // Si l'URL de base est vide, la connexion a échoué
        debugPrint('URL de base vide. Connexion au serveur échouée.');
        return ServerStatus.disconnected;
      }
    } catch (error) {
      // Gérer les erreurs de connexion
      debugPrint('Erreur de connexion au serveur: $error');
      return ServerStatus.disconnected;
    }
  }


// void _onLoadingSynchronisation(
  //     LoadingSynchronisation event,
  //     Emitter<ServerStatus> emit,
  //     ) async {
  //   emit(ServerStatus.synchronizing);
  //   try {
  //     // Appel de la méthode syncUsers pour synchroniser les utilisateurs
  //     final bool? syncSuccess = await syncService.syncUsers();
  //
  //     if (syncSuccess == true) {
  //       emit(ServerStatus.synchronizationSuccess);
  //     } else {
  //       emit(ServerStatus.synchronizationError);
  //     }
  //
  //   } catch (error) {
  //     debugPrint('Erreur lors de la synchronisation: $error');
  //     emit(ServerStatus.synchronizationError);
  //   }
  // }
}
