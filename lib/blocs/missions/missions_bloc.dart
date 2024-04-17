import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_rano/blocs/missions/missions_event.dart';
import 'package:application_rano/blocs/missions/missions_state.dart';
import 'package:application_rano/data/repositories/missions_repository.dart';

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
      await missionsRepository.fetchMissions(event.accessToken);
      emit(MissionsLoading(missions));
      emit(MissionsLoaded(missions));
    } catch (e) {
      print(e.toString());
      emit(MissionsLoadFailure(e.toString()));
    }
  }

  void _onAddMission(AddMission event, Emitter<MissionsState> emit) async {
    try {
      print('mission : ${event.accessToken}');
      await missionsRepository.createMission(
        event.missionId,
        event.adresseClient,
        event.consoValue,
        event.date,
      );

      // Émettre un état pour indiquer que la mission a été créée avec succès
      emit(MissionAdded());
    } catch (e) {
      emit(MissionsLoadFailure(e.toString()));
    }
  }

  void _onUpdateMission(UpdateMission event, Emitter<MissionsState> emit) async {
    try {
      print('mission : ${event.accessToken}');
      await missionsRepository.UpdateMission(
        event.missionId,
        event.adresseClient,
        event.consoValue,
        event.date,
      );

      // Émettre un état pour indiquer que la mission a été créée avec succès
      emit(MissionAdded());
    } catch (e) {
      emit(MissionsLoadFailure(e.toString()));
    }
  }
}
