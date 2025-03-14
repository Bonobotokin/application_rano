import 'dart:async';
import 'package:bloc/bloc.dart';
import 'send_data_event.dart';
import 'send_data_state.dart';
// /send_data/send_data_bloc
class SendDataBloc extends Bloc<SendDataEvent, SendDataState> {

  SendDataBloc() : super(SendDataInitial());

  Stream<SendDataState> mapEventToState(SendDataEvent event) async* {
    if (event is StartSendingData) {
      yield* _mapStartSendingDataToState(event);
    } else if (event is DataSent) {
      yield* _mapDataSentToState(event);
    }
  }

  Stream<SendDataState> _mapStartSendingDataToState(StartSendingData event) async* {
    int sentData = 0;
    final int totalDataToSend = event.totalDataToSend;

    yield SendDataLoading(); // Émettre l'état Loading au début de l'envoi

    while (sentData < totalDataToSend) {
      // Simuler l'envoi de données
      await Future.delayed(const Duration(milliseconds: 100));

      sentData += 50; // Simuler l'envoi de 50 données à la fois

      if (sentData >= totalDataToSend) {
        yield SendDataComplete();
        yield SendDataSuccess(); // Émettre l'état Success lorsque l'envoi est terminé avec succès
      } else {
        yield SendingInProgress(sentData: sentData, totalDataToSend: totalDataToSend);
      }
    }
  }

  Stream<SendDataState> _mapDataSentToState(DataSent event) async* {
    try {
      // Logique facultative à exécuter après l'envoi des données

      // Si tout va bien, nous n'émettons aucun nouvel état car l'envoi est déjà terminé avec succès
    } catch (error) {
      yield SendDataFailure(error.toString()); // Correction: Fournir l'argument 'error'
    }
  }

}
