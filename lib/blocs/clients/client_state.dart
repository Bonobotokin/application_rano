import 'package:equatable/equatable.dart';
import 'package:application_rano/data/models/client_model.dart';
import 'package:application_rano/data/models/compteur_model.dart';
import 'package:application_rano/data/models/contrat_model.dart';
import 'package:application_rano/data/models/releves_model.dart';

abstract class ClientState extends Equatable {
  const ClientState();

  @override
  List<Object> get props => [];
}

class ClientInitial extends ClientState {}

class ClientLoading extends ClientState {}

class ClientLoaded extends ClientState {
  final ClientModel client;
  final List<CompteurModel> compteur; // Modifier la déclaration de compteur
  final ContratModel contrat;
  final List<RelevesModel> releves;

  const ClientLoaded({
    required this.client,
    required this.compteur,
    required this.contrat,
    required this.releves,
  });

  @override
  List<Object> get props => [client, compteur, contrat, releves];
}

class ClientError extends ClientState {
  final String message;

  const ClientError({required this.message});

  @override
  List<Object> get props => [message];
}
