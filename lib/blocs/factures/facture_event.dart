// Dans facture_event.dart
import 'package:equatable/equatable.dart';

abstract class FactureEvent extends Equatable {
  const FactureEvent();

  @override
  List<Object> get props => [];
}

class FactureBillEvent extends FactureEvent {} // Renommé en FactureBillEvent

