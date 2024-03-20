import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/releves_model.dart';
import 'payement_state.dart';
import 'payement_event.dart';
import 'package:application_rano/data/repositories/local/facture_local_repository.dart';
import 'package:application_rano/data/repositories/client_repository.dart';
import 'package:application_rano/data/repositories/relever_repository.dart';


class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {

  final FactureLocalRepository factureLocalRepository ;
  final ClientRepository clientRepository;
  final ReleverRepository releverRepository;

  PaymentBloc({
    required this.factureLocalRepository,
    required this.clientRepository,
    required this.releverRepository
  }) : super(PaymentInitial()) {

    on<LoadPayment>(_onloadPayement);

    on<UpdateFacture>(_onUpdateFacture);
  }

  void _onloadPayement(LoadPayment event, Emitter<PaymentState> emit) async {
    try {
      print("teste locale ${event.numCompteur}");

      final factureData = await factureLocalRepository.getFactureById(event.numCompteur);
      final factures = factureData['factures'];

      final clientData = await clientRepository.fetchClientData(
          event.numCompteur, event.accessToken);
      final client = clientData['client'];

      print("tokin ${event.numCompteur} et ${event.date}");
      final releverData = await clientRepository.getReleverByDate(event.numCompteur, event.date);
      print("Zandry $releverData");

      // Attendre que le futur soit résolu pour accéder aux données
      final specificDateReleves = releverData['specificDateReleves'] ?? <RelevesModel>[];
      final previousDateReleves = releverData['previousDateReleves'] ?? <RelevesModel>[];

      emit(PayementLoading());
      emit(PayementLoaded(client, specificDateReleves, previousDateReleves, factures));
    } catch (e) {
      print(e.toString());
      emit(PaymentFailure(e.toString()));
    }
  }

  void _onUpdateFacture(UpdateFacture event, Emitter<PaymentState> emit) async {
    try {
      // Effectuez les opérations nécessaires pour mettre à jour la facture ici
      // Émettez ensuite un nouvel état pour indiquer que la mise à jour est terminée avec succès
      emit(PaymentSuccess()); // Par exemple
    } catch (e) {
      emit(PaymentFailure(e.toString())); // Émettre un état d'échec en cas d'erreur
    }
  }

}
