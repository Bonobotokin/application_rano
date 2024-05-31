import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/client_model.dart';
import '../../data/models/compteur_model.dart';
import '../../data/models/facture_model.dart';
import 'facture_event.dart';
import 'facture_state.dart';
import 'package:application_rano/data/repositories/client_repository.dart';

class FactureBloc extends Bloc<FactureEvent, FactureState> {
  final ClientRepository clientRepository;
  FactureBloc({required this.clientRepository}) : super(FactureInitial()) {
    on<LoadClientFacture>(_onLoadClientFacture);
    on<LoadClientInvoices>(_onLoadClientInvoices); // Ajoutez cet événement
  }

  void _onLoadClientFacture(
      LoadClientFacture event, Emitter<FactureState> emit) async {
    try {
      emit(LoadingPage());

      final clientData = await clientRepository.getAllClient(event.accessToken);
      final clients = clientData['clients'] as List<ClientModel>;
      final compteurs = clientData['compteurs'] as List<CompteurModel>;
      final nombreEtatImpaye = clientData['nombre'] as List<int>;
      final nombreEtatPaye = clientData['payer'] as List<int>; // Ajoutez cette ligne

      print("Clients: $clients");
      print("Compteurs: $compteurs");
      emit(FactureLoading(
        clients: clients,
        compteurs: compteurs,
        nombreEtatImpaye: nombreEtatImpaye,
        nombreEtatPaye: nombreEtatPaye, // Ajoutez cette ligne
      ));
      emit(FactureLoaded(
        clients: clients,
        compteurs: compteurs,
        nombreEtatImpaye: nombreEtatImpaye,
        nombreEtatPaye: nombreEtatPaye, // Ajoutez cette ligne
      ));
    } catch (e) {
      print(e.toString());

      emit(FactureFailure("Aucune Client"));
    }
  }

  void _onLoadClientInvoices(
      LoadClientInvoices event, Emitter<FactureState> emit) async {
    try {

      print("compteurIddd ${event.numCompteur}");
      emit(LoadingPage());
      print("eto ClientDataeeee ${event.numCompteur}");
      final clientData = await clientRepository.fetcDataFacture(
          event.numCompteur, event.accessToken);
      print("eto ClientDatass $clientData");
      final client = clientData['client'];
      final compteur = clientData['compteur'];
      final contrat = clientData['contrat'];
      final releves = clientData['releves'];

      emit(FactureClientLoading(client: client,
        compteur: [compteur],
        contrat: contrat,
        releves: releves,));
      emit(FactureClientLoaded(client: client,
        compteur: [compteur],
        contrat: contrat,
        releves: releves,)); // Ajouter le client dans une liste
    } catch (e) {
      print(e.toString());
      emit(FactureFailure(e.toString()));
    }
  }


}
