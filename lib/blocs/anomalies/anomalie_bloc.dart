import 'package:application_rano/blocs/anomalies/anomalie_event.dart';
import 'package:application_rano/blocs/anomalies/anomalie_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_rano/data/repositories/anomalie/anomalie_repository.dart';

class AnomalieBLoc extends Bloc<AnomalieEvent, AnomalieState>{
  final AnomalieRepository anomalieRepository;

  AnomalieBLoc({ required this.anomalieRepository }) : super(AnomalieInitial()){
    on<LoadAnomalie>((event, emit) async {
      try{
        final anomalie = await anomalieRepository.fetchAnomaleData(event.accessToken);

        emit(AnomalieLoading(anomalie));
        emit(AnomalieLoaded(anomalie));
      }
      catch(error) {
        print(AnomalieError('Failed to load Anomalie : $error'));
        emit(AnomalieError('Failed to load Anomalie: $error'));

      }
    });
  }
}