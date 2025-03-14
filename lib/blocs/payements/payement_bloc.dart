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
      emit(PayementLoading()); // Passer les données de paiement de la facture ici
      final getAllFacturessss = await factureLocalRepository.getFactureDataFromLocalDatabase();

      print("all Facture ${getAllFacturessss}");
      print("releveCompteurId ${event.relevecompteurId}");
      print("numCompteurss ${event.numCompteur}");

      final factureData = await factureLocalRepository.getFactureById(event.relevecompteurId);
      final factures = factureData['factures'];

      print("facturesByid ${factures}");
      final statusPayment = await factureLocalRepository.getStatuPaymentFacture(factures.id);

      print("Status Facture ${statusPayment['payment']}");
      final paymentData = statusPayment['payment'];

      final clientData = await clientRepository.fetcClientDataFacture(
          event.relevecompteurId, event.accessToken);
      final client = clientData['client'];

      final releverData = await clientRepository.getReleverByDate(event.numCompteur, event.date);
      print("Zandry $releverData");

      // Attendre que le futur soit résolu pour accéder aux données
      final specificDateReleves = releverData['specificDateReleves'] ?? <RelevesModel>[];
      final previousDateReleves = releverData['previousDateReleves'] ?? <RelevesModel>[];


      emit(PayementLoaded(client, specificDateReleves, previousDateReleves, factures, paymentData)); // Passer les données de paiement de la facture ici
    } catch (e) {
      print(e.toString());
      emit(PaymentFailure(e.toString()));
    }
  }

  void _onUpdateFacture(UpdateFacture event, Emitter<PaymentState> emit) async {
    try {
      // Effectuez les opérations nécessaires pour mettre à jour la facture ici
      await factureLocalRepository.savePayementFactureLocal(event.idFacture, event.montant);
      // Émettez ensuite un nouvel état pour indiquer que la mise à jour est terminée avec succès
      emit(PaymentSuccess(true)); // Passer les données de paiement de la facture ici
    } catch (e) {
      emit(PaymentFailure(e.toString())); // Émettre un état d'échec en cas d'erreur
    }
  }

  // void _onReloadPayment(ReloadPayment event, Emitter<PaymentState> emit) {
  //   // Méthode pour recharger les données et émettre à nouveau PayementLoaded
  //   add(ReloadPayments(relevecompteurId, numCompteur, date, accessToken));
  // }

}
