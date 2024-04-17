import 'package:application_rano/data/models/facture_model.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/client_model.dart';
import '../../data/models/compteur_model.dart';
import '../../data/models/contrat_model.dart';
import '../../data/models/releves_model.dart';

abstract class FactureState extends Equatable {
  const FactureState();

  @override
  List<Object> get props => [];

  get client => null;
}

class FactureInitial extends FactureState {}

class LoadingPage extends FactureState {}

class FactureLoading extends FactureState {
  final List<ClientModel> clients;
  final List<CompteurModel> compteurs;
  final List<int> nombreEtatImpaye;
  final List<int> nombreEtatPaye; // Ajoutez la liste nombreEtatPaye

  const FactureLoading({
    required this.clients,
    required this.compteurs,
    required this.nombreEtatImpaye,
    required this.nombreEtatPaye, // Ajoutez la liste nombreEtatPaye
  });

  @override
  List<Object> get props => [clients,compteurs,nombreEtatImpaye,nombreEtatPaye]; // Ajoutez la liste nombreEtatPaye
}

class FactureLoaded extends FactureState {
  final List<ClientModel> clients;
  final List<CompteurModel> compteurs;
  final List<int> nombreEtatImpaye;
  final List<int> nombreEtatPaye; // Ajoutez la liste nombreEtatPaye

  const FactureLoaded({
    required this.clients,
    required this.compteurs,
    required this.nombreEtatImpaye,
    required this.nombreEtatPaye, // Ajoutez la liste nombreEtatPaye
  });

  @override
  List<Object> get props => [clients,compteurs,nombreEtatImpaye,nombreEtatPaye]; // Ajoutez la liste nombreEtatPaye
}

class FactureClientLoading extends FactureState {
  final ClientModel client;
  final List<CompteurModel> compteur; // Modifier la déclaration de compteur
  final ContratModel contrat;
  final List<RelevesModel> releves;

  const FactureClientLoading({
    required this.client,
    required this.compteur,
    required this.contrat,
    required this.releves,
  });

  @override
  List<Object> get props => [client, compteur, contrat, releves];
}

class FactureClientLoaded extends FactureState {
  final ClientModel client;
  final List<CompteurModel> compteur; // Modifier la déclaration de compteur
  final ContratModel contrat;
  final List<RelevesModel> releves;

  const FactureClientLoaded({
    required this.client,
    required this.compteur,
    required this.contrat,
    required this.releves,
  });

  @override
  List<Object> get props => [client, compteur, contrat, releves];
}

class FactureFailure extends FactureState {
  final String message;

  const FactureFailure(this.message);

  @override
  List<Object> get props => [message];
}
