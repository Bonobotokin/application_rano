import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_rano/blocs/missions/missions_event.dart';
import 'package:application_rano/blocs/missions/missions_state.dart';
import 'package:application_rano/data/repositories/missions_repository.dart';
import 'package:path_provider/path_provider.dart';

class MissionsBloc extends Bloc<MissionsEvent, MissionsState> {
  final MissionsRepository missionsRepository;

  MissionsBloc({required this.missionsRepository}) : super(MissionsInitial()) {
    on<LoadMissions>(_onLoadMissions);

    on<AddMission>(_onAddMission);

    on<UpdateMission>(_onUpdateMission);
  }

  void _onLoadMissions(LoadMissions event, Emitter<MissionsState> emit) async {
    try {
      final missions =
      await missionsRepository.fetchMissions();
      emit(MissionsLoading(missions));
      emit(MissionsLoaded(missions));
    } catch (e) {
      print(e.toString());
      emit(MissionsLoadFailure(e.toString()));
    }
  }

  void _onAddMission(AddMission event, Emitter<MissionsState> emit) async {
    try {
      // Copier l'image dans le répertoire d'assets/images et obtenir le nouveau chemin
      String? newImagePath = await _copyImageToAssetsDirectory(event.imageCompteur);
      print('mission Image : $newImagePath');
      // Vérifier si la copie de l'image s'est bien déroulée
      if (newImagePath != null) {
        await missionsRepository.createMission(
            event.missionId,
            event.adresseClient,
            event.consoValue,
            event.date,
            newImagePath
        );
        emit(MissionAdded());
      } else {
        // Si la copie de l'image a échoué, émettre un état d'échec
        emit(MissionsLoadFailure("Échec de la copie de l'image"));
      }
      // Émettre un état pour indiquer que la mission a été créée avec succès

    } catch (e) {
      emit(MissionsLoadFailure(e.toString()));
    }
  }

  void _onUpdateMission(UpdateMission event, Emitter<MissionsState> emit) async {
    try {
      print('mission Image : ${event.imageCompteur}');

      // Copier l'image dans le répertoire d'assets/images et obtenir le nouveau chemin
      String? newImagePath = await _copyImageToAssetsDirectory(event.imageCompteur);

      // Vérifier si la copie de l'image s'est bien déroulée
      if (newImagePath != null) {
        // Mettre à jour la mission avec le nouveau chemin de l'image
        await missionsRepository.UpdateMission(
            event.missionId,
            event.adresseClient,
            event.consoValue,
            event.date,
            newImagePath
        );

        // Émettre un état pour indiquer que la mission a été mise à jour avec succès
        emit(MissionUpdated());
      } else {
        // Si la copie de l'image a échoué, émettre un état d'échec
        emit(MissionsLoadFailure("Échec de la copie de l'image"));
      }
    } catch (e) {
      emit(MissionsLoadFailure(e.toString()));
    }
  }


  Future<String?> _copyImageToAssetsDirectory(String imagePath) async {
    try {
      // Obtenir le répertoire d'assets/images
      final Directory appDirectory = await getApplicationDocumentsDirectory();
      final String assetsDirectory = '${appDirectory.path}/assets/images';
      print("eeee ${appDirectory.path}/assets/images");

      // Vérifier si le répertoire d'assets/images existe, sinon le créer
      final bool assetsExists = await Directory(assetsDirectory).exists();
      if (!assetsExists) {
        await Directory(assetsDirectory).create(recursive: true);
      }

      // Générer un nom de fichier abrégé en utilisant la date actuelle
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Copier l'image dans le répertoire d'assets/images
      String destinationPath = path.join(assetsDirectory, fileName);
      await File(imagePath).copy(destinationPath);

      print('Image copiée dans le répertoire d\'assets/images avec succès.');

      return destinationPath; // Retourner le chemin de l'image copiée
    } catch (e) {
      print('Erreur lors de la copie de l\'image dans le répertoire d\'assets/images: $e');
      return null; // Retourner null en cas d'erreur
    }
  }

}
