import 'package:equatable/equatable.dart';
import 'package:application_rano/data/models/facture_model.dart';
import 'package:application_rano/data/models/client_model.dart';
import 'package:application_rano/data/models/releves_model.dart';

// États
abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object> get props => [];
}

class PaymentInitial extends PaymentState {}

class PayementLoading extends PaymentState {
  // final List<FactureModel> factures;
  //
  // const PayementLoading(this.factures);
  //
  // @override
  // List<Object> get props => [factures];
}

class PayementLoaded extends PaymentState {
  final ClientModel client;
  final List<RelevesModel> specificDateReleves;
  final List<RelevesModel> previousDateReleves;
  final FactureModel factures;

  const PayementLoaded(
      this.client,
      this.specificDateReleves,
      this.previousDateReleves,
      this.factures
      );

  @override
  List<Object> get props => [client, specificDateReleves, previousDateReleves, factures];
}



class PaymentInProgress extends PaymentState {}

class PaymentSuccess extends PaymentState {}

class PaymentFailure extends PaymentState {
  final String message;

  const PaymentFailure(this.message);

  @override
  List<Object> get props => [message];
}