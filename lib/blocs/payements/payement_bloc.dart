import 'dart:async';
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'payement_state.dart';
import 'payement_event.dart';
import 'package:application_rano/data/models/facture_model.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc() : super(PaymentInitial());

  @override
  Stream<PaymentState> mapEventToState(PaymentEvent event) async* {
    if (event is MakePayment) {
      // Mettez ici la logique de traitement de l'événement MakePayment
      yield PaymentInProgress(); // Par exemple, indiquez que le paiement est en cours
      try {
        // Effectuez le paiement
        yield PaymentSuccess(); // Le paiement a réussi
      } catch (error) {
        yield PaymentFailure(error.toString()); // Le paiement a échoué
      }
    }
  }
}
