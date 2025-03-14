import 'package:equatable/equatable.dart';
import 'package:application_rano/data/models/missions_model.dart';

abstract class MissionsState extends Equatable {
  const MissionsState();

  @override
  List<Object> get props => [];
}

class MissionsInitial extends MissionsState {}

class MissionsLoading extends MissionsState {

}

class MissionsLoaded extends MissionsState {
  final List<MissionModel> missions;

  const MissionsLoaded(this.missions);

  @override
  List<Object> get props => [missions];
}

class MissionsLoadFailure extends MissionsState {
  final String error;

  const MissionsLoadFailure(this.error);

  @override
  List<Object> get props => [error];
}

class MissionAdded extends MissionsState {
  // Vous pouvez ajouter des propriétés supplémentaires si nécessaire
}

class MissionUpdated extends MissionsState {
  // Vous pouvez ajouter des propriétés supplémentaires si nécessaire
}
