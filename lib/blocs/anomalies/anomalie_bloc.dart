import 'package:application_rano/blocs/anomalies/anomalie_event.dart';
import 'package:application_rano/blocs/anomalies/anomalie_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_rano/data/repositories/anomalie/anomalie_repository.dart';

class AnomalieBLoc extends Bloc<AnomalieEvent, AnomalieState>{
  final AnomalieRepository anomalieRepository;

  AnomalieBLoc({ required this.anomalieRepository }) : super(AnomalieInitial()) {
    on<LoadAnomalie>(_onLoadAnomalie);

    on<AddAnomalie>(_onAddMission);
  }
  void _onLoadAnomalie(LoadAnomalie event , Emitter<AnomalieState> emit) async{
    try{
      final anomalie = await anomalieRepository.fetchAnomaleData(event.accessToken);
      print(anomalie);
      emit(AnomalieLoading(anomalie));
      emit(AnomalieLoaded(anomalie));
    }
    catch(error) {
      print(AnomalieError('Failed to load Anomalie : $error'));
      emit(AnomalieError('Failed to load Anomalie: $error'));

    }
  }

  void _onAddMission(AddAnomalie event, Emitter<AnomalieState> emit) async {
    try {
      // Appelez la méthode de votre repository pour ajouter la nouvelle anomalie

      // print("Création d'une anomalie avec les données suivantes :");
      // print("Type : ${event.typeMc}");
      // print("Date de déclaration : ${event.dateDeclaration}");
      // print("Longitude : ${event.longitudeMc}");
      // print("Latitude : ${event.latitudeMc}");
      // print("Description : ${event.descriptionMc}");
      // print("Client : ${event.clientDeclare}");
      // print("Code postal commune : ${event.cpCommune}");
      // print("Commune : ${event.commune}");
      // print("Statut : ${event.status}");
      // Chargez à nouveau les anomalies après l'ajout de la nouvelle anomalie
      final anomalie = await anomalieRepository.createAnomalie(
          event.typeMc, event.dateDeclaration, event.longitudeMc, event.latitudeMc, event.descriptionMc, event.clientDeclare,
          event.cpCommune, event.commune,event.status);

    } catch (error) {
      // En cas d'erreur, émettez un état d'erreur avec un message approprié
      emit(AnomalieError('Failed to add Anomalie: $error'));
    }
  }


}

