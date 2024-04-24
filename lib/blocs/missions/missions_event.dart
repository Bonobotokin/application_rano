import 'package:equatable/equatable.dart';

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
  final String accessToken;
  final String imageCompteur;

  const AddMission({
    required this.missionId,
    required this.adresseClient,
    required this.consoValue,
    required this.date,
    required this.accessToken,
    required this.imageCompteur,
  });

  @override
  List<Object> get props =>
      [missionId, adresseClient, consoValue, date, accessToken,imageCompteur];

  @override
  String toString() =>
      'AddMission { missionId: $missionId, adresseClient: $adresseClient, consoValue: $consoValue, date: $date, accessToken: $accessToken, image: $imageCompteur }';
}

class UpdateMission extends MissionsEvent {
  final String missionId;
  final String adresseClient;
  final String consoValue;
  final String date;
  final String accessToken; // Ajoutez cette propriété
  final String imageCompteur;

  const UpdateMission({
    required this.missionId,
    required this.adresseClient,
    required this.consoValue,
    required this.date,
    required this.accessToken,
    required this.imageCompteur
  });

  @override
  List<Object> get props =>
      [missionId, adresseClient, consoValue, date, accessToken, imageCompteur ];

  @override
  String toString() =>
      'UpdateMission { missionId: $missionId, adresseClient: $adresseClient, consoValue: $consoValue, date: $date, accessToken: $accessToken, image: $imageCompteur }';
}
