import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:application_rano/blocs/anomalies/anomalie_event.dart';
import 'package:application_rano/blocs/anomalies/anomalie_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_rano/data/repositories/anomalie/anomalie_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class AnomalieBLoc extends Bloc<AnomalieEvent, AnomalieState>{
  final AnomalieRepository anomalieRepository;

  AnomalieBLoc({ required this.anomalieRepository }) : super(AnomalieInitial()) {
    on<LoadAnomalie>(_onLoadAnomalie);

    on<AddAnomalie>(_onAddAnomalie);

    on<GetUpdateAnomalie>(_onGetUpdateAnomalie);

    on<UpdateAnomalie>(_onUpdateAnomalie);
  }
  void _onLoadAnomalie(LoadAnomalie event, Emitter<AnomalieState> emit) async {
    try {

      emit(AnomalieLoading()); // Émettre l'état de chargement
      final anomalie = await anomalieRepository.fetchAnomaleData(event.accessToken);
      print("eto anomalie Page $anomalie");

      emit(AnomalieLoaded(anomalie));
    } catch (error) {
      print('Failed to load Anomalie: $error');
      emit(AnomalieError('Failed to load Anomalie: $error'));
    }
  }


  void _onAddAnomalie(AddAnomalie event, Emitter emit) async {
    try {
      String dateStr = event.dateDeclaration;
      DateFormat inputFormat = DateFormat("dd-MM-yyyy");
      DateFormat outputFormat = DateFormat("yyyy-MM-dd");

      DateTime date = inputFormat.parse(dateStr);
      String formattedDate = outputFormat.format(date);

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
        formattedDate,
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


  void _onUpdateAnomalie(UpdateAnomalie event, Emitter emit) async {
    try {
      String dateStr = event.anomalieItem.dateDeclaration!;
      DateFormat inputFormat = DateFormat("dd-MM-yyyy");
      DateFormat outputFormat = DateFormat("yyyy-MM-dd");

      DateTime date = inputFormat.parse(dateStr);
      String formattedDate = outputFormat.format(date);
      List<String?> newImagePaths = [];

      // // Ajouter les chemins d'accès des images s'ils existent
      if (event.anomalieItem.photoAnomalie1 != null) {
        newImagePaths.add(await _copyImageToAssetsDirectory(event.anomalieItem.photoAnomalie1!));
      }
      if (event.anomalieItem.photoAnomalie2 != null) {
        newImagePaths.add(await _copyImageToAssetsDirectory(event.anomalieItem.photoAnomalie2!));
      }
      if (event.anomalieItem.photoAnomalie3 != null) {
        newImagePaths.add(await _copyImageToAssetsDirectory(event.anomalieItem.photoAnomalie3!));
      }
      if (event.anomalieItem.photoAnomalie4 != null) {
        newImagePaths.add(await _copyImageToAssetsDirectory(event.anomalieItem.photoAnomalie4!));
      }
      if (event.anomalieItem.photoAnomalie5 != null) {
        newImagePaths.add(await _copyImageToAssetsDirectory(event.anomalieItem.photoAnomalie5!));
      }
      // Appeler la méthode createAnomalie avec la liste des nouveaux chemins d'image
      final anomalie = await anomalieRepository.updateAnomalie(
        event.anomalieItem.idMc,
        event.anomalieItem.typeMc,
        formattedDate,
        event.anomalieItem.longitudeMc,
        event.anomalieItem.latitudeMc,
        event.anomalieItem.descriptionMc,
        event.anomalieItem.clientDeclare,
        event.anomalieItem.cpCommune,
        event.anomalieItem.commune,
        newImagePaths,
      );
      //

    } catch (error) {
      // En cas d'erreur, émettez un état d'erreur avec un message approprié
      emit(AnomalieError('Failed to add Anomalie: $error'));
    }
  }


  // Future<String?> _copyImageToAssetsDirectory(String? imagePath) async {
  //   try {
  //     // Obtenir le répertoire d'assets/images
  //     final Directory appDirectory = await getApplicationDocumentsDirectory();
  //     final String assetsDirectory = '${appDirectory.path}/assets/images';
  //
  //     // Vérifier si le répertoire d'assets/images/anomalie existe, sinon le créer
  //     final bool assetsExists = await Directory(assetsDirectory).exists();
  //     if (!assetsExists) {
  //       await Directory(assetsDirectory).create(recursive: true);
  //     }
  //
  //     // Générer un nom de fichier abrégé en utilisant la date actuelle
  //     final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
  //
  //     // Copier l'image dans le répertoire d'assets/images
  //     String destinationPath = path.join(assetsDirectory, fileName);
  //     await File(imagePath!).copy(destinationPath);
  //
  //     print('Image copiée dans le répertoire d\'assets/images avec succès.');
  //
  //     return destinationPath; // Retourner le chemin de l'image copiée
  //   } catch (e) {
  //     print('Erreur lors de la copie de l\'image dans le répertoire d\'assets/images: $e');
  //     return null; // Retourner null en cas d'erreur
  //   }
  // }


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

      // Lire le fichier image à compresser
      File imageFile = File(imagePath!);
      Uint8List bytes = await imageFile.readAsBytes();

      // Définir la qualité et les dimensions cibles de l'image compressée
      int quality = 80; // Qualité de compression (0 - 100)
      int maxWidth = 1080; // Largeur maximale après compression
      int maxHeight = 1920; // Hauteur maximale après compression

      // Décoder l'image à l'aide de la bibliothèque image
      img.Image? image = img.decodeImage(bytes);

      if (image != null) {
        // Redimensionner l'image si nécessaire
        if (image.width > maxWidth || image.height > maxHeight) {
          image = img.copyResize(image, width: maxWidth, height: maxHeight);
        }

        // Encoder l'image avec la qualité spécifiée
        Uint8List compressedBytes = img.encodeJpg(image, quality: quality);

        // Générer un nom de fichier abrégé en utilisant la date actuelle
        final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

        // Chemin de destination pour l'image compressée
        String destinationPath = path.join(assetsDirectory, fileName);

        // Écrire l'image compressée dans le répertoire d'assets/images
        File(destinationPath).writeAsBytesSync(compressedBytes);

        print('Image compressée et copiée dans le répertoire d\'assets/images avec succès.');

        return destinationPath; // Retourner le chemin de l'image compressée
      } else {
        print('Erreur: Impossible de décoder l\'image.');
        return null; // Retourner null en cas d'erreur de décodage de l'image
      }
    } catch (e) {
      print('Erreur lors de la compression et copie de l\'image: $e');
      return null; // Retourner null en cas d'erreur
    }
  }

  void _onGetUpdateAnomalie(GetUpdateAnomalie event, Emitter emit) async {
    try {

      print("verrifiIdMC : ${event.idMc}");
      final anomalieList = await anomalieRepository.fetchAnomaleDataByIdMc(event.idMc);
      print("teto : $anomalieList");
      final anomalie = anomalieList.isNotEmpty ? anomalieList.first : null;

      // Vérifiez si l'anomalie a été récupérée avec succès
      if (anomalie != null) {
        // Émettez l'état AnomalieLoaded avec l'anomalie récupérée
        print("mandea $anomalie");
        emit(AnomalieUpdateLoading([anomalie]));
        emit(AnomalieUpdateLoaded([anomalie]));
      } else {
        // Si l'anomalie est null, cela peut signifier qu'il n'y a pas de données à charger
        // Dans ce cas, émettez un état AnomalieError avec un message approprié
        emit(AnomalieError("No anomalie data found for id: ${event.idMc}"));
      }
    } catch (e) {
      // En cas d'erreur lors de la récupération des données, émettez un état AnomalieError avec le message d'erreur
      emit(AnomalieError("Failed to get anomalie update data: $e"));
    }
  }

}

