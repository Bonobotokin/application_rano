import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_rano/blocs/clients/client_event.dart';
import 'package:application_rano/blocs/clients/client_state.dart';
import 'package:application_rano/data/repositories/client_repository.dart';

class ClientBloc extends Bloc<ClientEvent, ClientState> {
  final ClientRepository clientRepository;

  ClientBloc({required this.clientRepository}) : super(ClientInitial()) {
    on<LoadClients>(_onLoadClients);
  }

  void _onLoadClients(LoadClients event, Emitter<ClientState> emit) async {
    try {
      emit(ClientLoading());

      print("eto ClientData ${event.numCompteur}");
      final clientData = await clientRepository.fetchClientData(
          event.numCompteur, event.accessToken);
      print("eto ClientData $clientData");
      final client = clientData['client'];
      final compteur = clientData['compteur'];
      final contrat = clientData['contrat'];
      final releves = clientData['releves'];

      emit(ClientLoaded(
        client: client,
        compteur: [compteur],
        contrat: contrat,
        releves: releves,
      ));
    } catch (e) {
      print(ClientError(message: 'Failed to load client data $e'));
      emit(const ClientError(message: 'Failed to load client data'));
    }
  }
}
