import 'package:equatable/equatable.dart';
import 'package:application_rano/data/models/missions_model.dart';

abstract class AnomalieEvent extends Equatable {
  const AnomalieEvent();

  @override
  List<Object> get props => [];
}

class LoadAnomalie extends AnomalieEvent {
  final String accessToken;

  const LoadAnomalie({required this.accessToken});

  @override
  List<Object> get props => [accessToken];
}

class AddAnomalie extends AnomalieEvent {
  final String missionId;
  final String adresseClient;
  final String consoValue;
  final String date;
  final String accessToken; // Ajoutez cette propriété

  const AddAnomalie({
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

class AnomalieAdd extends AnomalieEvent {

}

class UpdateAnomalie extends AnomalieEvent {
  final String missionId;
  final String adresseClient;
  final String consoValue;
  final String date;
  final String accessToken; // Ajoutez cette propriété

  const UpdateAnomalie({
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
