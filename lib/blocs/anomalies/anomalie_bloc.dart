import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:application_rano/blocs/anomalies/anomalie_event.dart';
import 'package:application_rano/blocs/anomalies/anomalie_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_rano/data/repositories/anomalie/anomalie_repository.dart';
import 'package:path_provider/path_provider.dart';

class AnomalieBLoc extends Bloc<AnomalieEvent, AnomalieState>{
  final AnomalieRepository anomalieRepository;

  AnomalieBLoc({ required this.anomalieRepository }) : super(AnomalieInitial()) {
    on<LoadAnomalie>(_onLoadAnomalie);

    on<AddAnomalie>(_onAddAnomalie);

    on<GetUpdateAnomalie>(_onGetUpdateAnomalie);
    // on<UpdateAnomalie>(_onUpdateAnomalie);
  }
  void _onLoadAnomalie(LoadAnomalie event , Emitter<AnomalieState> emit) async{
    try{
      final anomalie = await anomalieRepository.fetchAnomaleData(event.accessToken);
      print("eto anomalie Page $anomalie");
      // final anomalie = anomalieListe['anomalie'];
      // final photoAnomalie = anomalieListe['photoAnomalie'];

      emit(AnomalieLoading(anomalie));
      emit(AnomalieLoaded(anomalie));
    }
    catch(error) {
      print(AnomalieError('Failed to load Anomalie : $error'));
      emit(AnomalieError('Failed to load Anomalie: $error'));

    }
  }

  void _onAddAnomalie(AddAnomalie event, Emitter emit) async {
    try {
      print("les images: ${event.imagePaths}");
      List<String?> newImagePaths = [];
      for (String? imagePath in event.imagePaths) {
        String? newImagePath = await _copyImageToAssetsDirectory(imagePath);
        if (newImagePath != null) {
          newImagePaths.add(newImagePath); // Ajouter le nouveau chemin d'image à la liste
        }
      }

      // Appeler la méthode createAnomalie avec la liste des nouveaux chemins d'image
      final anomalie = await anomalieRepository.createAnomalie(
        event.typeMc,
        event.dateDeclaration,
        event.longitudeMc,
        event.latitudeMc,
        event.descriptionMc,
        event.clientDeclare,
        event.cpCommune,
        event.commune,
        newImagePaths, // Utiliser la liste des nouveaux chemins d'image
      );

      print("les images data : $newImagePaths"); // Afficher les nouveaux chemins d'image

    } catch (error) {
      // En cas d'erreur, émettez un état d'erreur avec un message approprié
      emit(AnomalieError('Failed to add Anomalie: $error'));
    }
  }

  Future<String?> _copyImageToAssetsDirectory(String? imagePath) async {
    try {
      // Obtenir le répertoire d'assets/images
      final Directory appDirectory = await getApplicationDocumentsDirectory();
      final String assetsDirectory = '${appDirectory.path}/assets/images';

      // Vérifier si le répertoire d'assets/images/anomalie existe, sinon le créer
      final bool assetsExists = await Directory(assetsDirectory).exists();
      if (!assetsExists) {
        await Directory(assetsDirectory).create(recursive: true);
      }

      // Générer un nom de fichier abrégé en utilisant la date actuelle
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Copier l'image dans le répertoire d'assets/images
      String destinationPath = path.join(assetsDirectory, fileName);
      await File(imagePath!).copy(destinationPath);

      print('Image copiée dans le répertoire d\'assets/images avec succès.');

      return destinationPath; // Retourner le chemin de l'image copiée
    } catch (e) {
      print('Erreur lors de la copie de l\'image dans le répertoire d\'assets/images: $e');
      return null; // Retourner null en cas d'erreur
    }
  }

  void _onGetUpdateAnomalie(GetUpdateAnomalie event, Emitter emit) async {
    try{
      final anomalie = await anomalieRepository.createAnomalie();
    }
    cacth(e) {

    }

  }
}

