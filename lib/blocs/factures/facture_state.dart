// Dans facture_state.dart
import 'package:equatable/equatable.dart';

class FactureState extends Equatable {
  final bool isPaid;

  const FactureState({required this.isPaid});

  factory FactureState.initial() {
    return FactureState(isPaid: false);
  }

  FactureState copyWith({bool? isPaid}) {
    return FactureState(isPaid: isPaid ?? this.isPaid);
  }

  @override
  List<Object> get props => [isPaid];
}
