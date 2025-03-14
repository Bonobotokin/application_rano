import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:path/path.dart' as path;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_rano/blocs/missions/missions_event.dart';
import 'package:application_rano/blocs/missions/missions_state.dart';
import 'package:application_rano/data/repositories/missions_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class MissionsBloc extends Bloc<MissionsEvent, MissionsState> {
  final MissionsRepository missionsRepository;

  MissionsBloc({required this.missionsRepository}) : super(MissionsInitial()) {
    on<LoadMissions>(_onLoadMissions);
    on<AddMission>(_onAddMission);
    on<UpdateMission>(_onUpdateMission);
    on<SyncMissionsEvent>(_onSyncMissions); // Add this line
  }

  void _onLoadMissions(LoadMissions event, Emitter<MissionsState> emit) async {
    try {
      emit(MissionsLoading());

      final missions = await missionsRepository.fetchMissions();
      print("Nombre total de missions: ${missions.length}");
      print("Détails des missions: $missions");
      emit(MissionsLoaded(missions));
    } catch (e) {
      print(e.toString());
      emit(MissionsLoadFailure(e.toString()));
    }
  }

  void _onAddMission(AddMission event, Emitter<MissionsState> emit) async {
    try {
      String? newImagePath = await _copyImageToAssetsDirectory(event.imageCompteur);
      print('mission Image : $newImagePath');
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
        emit(MissionsLoadFailure("Échec de la copie de l'image"));
      }
    } catch (e) {
      emit(MissionsLoadFailure(e.toString()));
    }
  }

  void _onUpdateMission(UpdateMission event, Emitter<MissionsState> emit) async {
    try {
      print('mission Image : ${event.imageCompteur}');
      String? newImagePath = await _copyImageToAssetsDirectory(event.imageCompteur);
      print("reverrifiaction Image  $newImagePath");
      if (newImagePath != null) {
        await missionsRepository.UpdateMission(
            event.missionId,
            event.adresseClient,
            event.consoValue,
            event.date,
            newImagePath
        );
        emit(MissionUpdated());
      } else {
        emit(MissionsLoadFailure("Échec de la copie de l'image"));
      }
    } catch (e) {
      emit(MissionsLoadFailure(e.toString()));
    }
  }

  Future<String?> _copyImageToAssetsDirectory(String imagePath) async {
    try {
      final Directory appDirectory = await getApplicationDocumentsDirectory();
      final String assetsDirectory = '${appDirectory.path}/assets/images';
      final bool assetsExists = await Directory(assetsDirectory).exists();
      if (!assetsExists) {
        await Directory(assetsDirectory).create(recursive: true);
      }

      // Compress the image
      File imageFile = File(imagePath);
      Uint8List imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);
      if (image != null) {
        img.Image compressedImage = img.copyResize(image, width: 800); // Adjust dimensions as needed

        // Save compressed image to assets directory
        String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        String destinationPath = path.join(assetsDirectory, fileName);
        File compressedFile = File(destinationPath);
        await compressedFile.writeAsBytes(img.encodeJpg(compressedImage, quality: 85)); // Adjust quality as needed

        print('Image compressée et copiée dans le répertoire d\'assets/images avec succès.');
        return destinationPath;
      } else {
        print('Failed to decode image.');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la copie de l\'image dans le répertoire d\'assets/images: $e');
      return null;
    }
  }

  void _onSyncMissions(SyncMissionsEvent event, Emitter<MissionsState> emit) async {
    try {
      emit(MissionsLoading());
      final missions = await missionsRepository.fetchMissions();
      print("Nombre total de missions: ${missions.length}");
      print("Détails des missions: $missions");
      emit(MissionsLoaded(missions));
    } catch (e) {
      emit(MissionsLoadFailure(e.toString()));
    }
  }
}
