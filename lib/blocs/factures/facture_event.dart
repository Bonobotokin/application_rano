import 'dart:ffi';

import 'package:equatable/equatable.dart';

abstract class FactureEvent extends Equatable {
  const FactureEvent();

  @override
  List<Object> get props => [];
}

class LoadClientFacture extends FactureEvent {
  final String accessToken;

  const LoadClientFacture({
    required this.accessToken
  });

  @override
  List<Object> get props => [accessToken];
}

class LoadClientInvoices extends FactureEvent {
  final String accessToken;
  final int numCompteur;

  const LoadClientInvoices({required this.accessToken,required this.numCompteur});

  @override
  List<Object> get props => [accessToken];
}

class FactureBillEvent extends FactureEvent {}
