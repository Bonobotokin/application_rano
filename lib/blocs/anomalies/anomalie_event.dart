import 'package:application_rano/data/models/anomalie_model.dart';
import 'package:equatable/equatable.dart';

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
  final String typeMc;
  final String dateDeclaration;
  final String longitudeMc;
  final String latitudeMc;
  final String descriptionMc;
  final String clientDeclare;
  final String cpCommune;
  final String commune;
  final String status;
  final List<String?> imagePaths;

  const AddAnomalie({
    required this.typeMc,
    required this.dateDeclaration,
    required this.longitudeMc,
    required this.latitudeMc,
    required this.descriptionMc,
    required this.clientDeclare,
    required this.cpCommune,
    required this.commune,
    required this.status,
    required this.imagePaths,
  });

  @override
  List<Object> get props => [
    typeMc,
    dateDeclaration,
    longitudeMc,
    latitudeMc,
    descriptionMc,
    clientDeclare,
    cpCommune,
    commune,
    status,
    imagePaths,
  ];
}


class AnomalieAdd extends AnomalieEvent {

}


class GetUpdateAnomalie extends AnomalieEvent {
  final int idMc;

  const GetUpdateAnomalie({
    required this.idMc,
  });

  @override
  List<Object> get props => [
    idMc,
  ];
}


class UpdateAnomalie extends AnomalieEvent {
  final String typeMc;
  final String dateDeclaration;
  final String longitudeMc;
  final String latitudeMc;
  final String descriptionMc;
  final String clientDeclare;
  final String cpCommune;
  final String commune;
  final String status;
  final List<String?> imagePaths;

  const UpdateAnomalie({
    required this.typeMc,
    required this.dateDeclaration,
    required this.longitudeMc,
    required this.latitudeMc,
    required this.descriptionMc,
    required this.clientDeclare,
    required this.cpCommune,
    required this.commune,
    required this.status,
    required this.imagePaths,
  });

  @override
  List<Object> get props => [
    typeMc,
    dateDeclaration,
    longitudeMc,
    latitudeMc,
    descriptionMc,
    clientDeclare,
    cpCommune,
    commune,
    status,
    imagePaths,
  ];
}
