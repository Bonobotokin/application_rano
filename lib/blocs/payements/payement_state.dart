import 'package:equatable/equatable.dart';
import 'package:application_rano/data/models/facture_model.dart';
import 'package:application_rano/data/models/client_model.dart';
import 'package:application_rano/data/models/releves_model.dart';

import '../../data/models/facture_payment_model.dart';

// États
abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object> get props => [];
}

class PaymentInitial extends PaymentState {}

class PayementLoading extends PaymentState {
  final ClientModel client;
  final List<RelevesModel> specificDateReleves;
  final List<RelevesModel> previousDateReleves;
  final FactureModel factures;
  final FacturePaymentModel payment; // Ajouter un champ pour les données de paiement de la facture

  const PayementLoading(
      this.client,
      this.specificDateReleves,
      this.previousDateReleves,
      this.factures,
      this.payment, // Ajouter les données de paiement de la facture ici
      );

  @override
  List<Object> get props => [client, specificDateReleves, previousDateReleves, factures, payment];
}

class PayementLoaded extends PaymentState {
  final ClientModel client;
  final List<RelevesModel> specificDateReleves;
  final List<RelevesModel> previousDateReleves;
  final FactureModel factures;
  final FacturePaymentModel payment; // Ajouter un champ pour les données de paiement de la facture

  const PayementLoaded(
      this.client,
      this.specificDateReleves,
      this.previousDateReleves,
      this.factures,
      this.payment, // Ajouter les données de paiement de la facture ici
      );

  @override
  List<Object> get props => [client, specificDateReleves, previousDateReleves, factures, payment];
}



class PaymentInProgress extends PaymentState {}

class PaymentSuccess extends PaymentState {}

class PaymentFailure extends PaymentState {
  final String message;

  const PaymentFailure(this.message);

  @override
  List<Object> get props => [message];
}