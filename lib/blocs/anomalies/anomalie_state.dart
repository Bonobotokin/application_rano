import 'package:application_rano/data/models/anomalie_model.dart';
import 'package:equatable/equatable.dart';

abstract class AnomalieState extends Equatable {
  const AnomalieState();

  @override
  List<Object> get props => [];
}

class AnomalieInitial extends AnomalieState {}

class AnomalieLoading extends AnomalieState {

  final List<AnomalieModel> anomalie;

  const AnomalieLoading(this.anomalie);

  @override
  List<Object> get props => [anomalie];
}

class AnomalieLoaded extends AnomalieState {
  final List<AnomalieModel> anomalie;

  const AnomalieLoaded(this.anomalie);

  @override
  List<Object> get props => [anomalie];
}

class AnomalieError extends AnomalieState {
  final String message;

  const AnomalieError(this.message);

  @override
  List<Object> get props => [message];
}
