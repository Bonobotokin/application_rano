import 'package:equatable/equatable.dart';
import 'package:application_rano/data/models/missions_model.dart';

abstract class MissionsEvent extends Equatable {
  const MissionsEvent();

  @override
  List<Object> get props => [];
}

class LoadMissions extends MissionsEvent {
  final String accessToken;

  const LoadMissions({required this.accessToken});

  @override
  List<Object> get props => [accessToken];
}

class AddMission extends MissionsEvent {
  final String missionId;
  final String adresseClient;
  final String consoValue;
  final String date;
  final String accessToken; // Ajoutez cette propriété

  const AddMission({
    required this.missionId,
    required this.adresseClient,
    required this.consoValue,
    required this.date,
    required this.accessToken,
  });

  @override
  List<Object> get props =>
      [missionId, adresseClient, consoValue, date, accessToken];

  @override
  String toString() =>
      'AddMission { missionId: $missionId, adresseClient: $adresseClient, consoValue: $consoValue, date: $date, accessToken: $accessToken }';
}

class UpdateMission extends MissionsEvent {
  final String missionId;
  final String adresseClient;
  final String consoValue;
  final String date;
  final String accessToken; // Ajoutez cette propriété

  const UpdateMission({
    required this.missionId,
    required this.adresseClient,
    required this.consoValue,
    required this.date,
    required this.accessToken,
  });

  @override
  List<Object> get props =>
      [missionId, adresseClient, consoValue, date, accessToken];

  @override
  String toString() =>
      'UpdateMission { missionId: $missionId, adresseClient: $adresseClient, consoValue: $consoValue, date: $date, accessToken: $accessToken }';
}
