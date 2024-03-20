import 'dart:ffi';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:application_rano/data/models/releves_model.dart';

// Événements
abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object> get props => [];
}

class LoadPayment extends PaymentEvent {
  final String accessToken;
  final int relevecompteurId;
  final int numCompteur;
  final String date;

  const LoadPayment({
    required this.accessToken,
    required this.relevecompteurId,
    required this.numCompteur,
    required this.date
  });

  @override
  List<Object> get props => [accessToken,relevecompteurId,numCompteur,date];

  @override
  String toString() =>
      'LoadPayment {accessToken: $accessToken,relevecompteurId: $relevecompteurId,numCompteur: $numCompteur, date: $date}';
}

class UpdateFacture extends PaymentEvent {
  final int idFacture;
  final double montant; // Utilisez 'double' au lieu de 'Double'

  const UpdateFacture({
    required this.idFacture,
    required this.montant,
  });

  @override
  List<Object> get props => [idFacture, montant];

  @override
  String toString() => 'UpdateFacture { idFacture: $idFacture, montant: $montant }';
}


// class MakePayment extends PaymentEvent {}
//
// @override
// List<Object> get props =>
//     [accessToken];
//
// @override
// String toString() =>
//     ''

