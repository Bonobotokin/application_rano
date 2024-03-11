import 'package:flutter_bloc/flutter_bloc.dart';
import 'facture_event.dart';
import 'facture_state.dart';

class FactureBloc extends Bloc<FactureEvent, FactureState> {
  FactureBloc() : super(FactureState.initial());

  @override
  Stream<FactureState> mapEventToState(FactureEvent event) async* {
    if (event is FactureBillEvent) { // Utilisation de FactureBillEvent
      // Mettez ici la logique de paiement de la facture
      yield state.copyWith(isPaid: true);
    }
  }
}
