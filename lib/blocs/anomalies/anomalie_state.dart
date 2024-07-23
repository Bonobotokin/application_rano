import 'package:application_rano/data/models/anomalie_model.dart';
import 'package:application_rano/data/models/photo_anomalie_model.dart';
import 'package:equatable/equatable.dart';

abstract class AnomalieState extends Equatable {
  const AnomalieState();

  @override
  List<Object> get props => [];
}

class AnomalieInitial extends AnomalieState {}

class UpdateAnomalieLoading extends AnomalieState {
  final List<AnomalieModel> anomalie;

  const UpdateAnomalieLoading(this.anomalie);

  @override
  List<Object> get props => [anomalie];
}

class AnomalieLoading extends AnomalieState {
}

class AnomalieLoaded extends AnomalieState {
  final List<AnomalieModel> anomalie;

  const AnomalieLoaded(this.anomalie);

  @override
  List<Object> get props => [anomalie];
}

class AnomalieUpdateLoading extends AnomalieState {
  final List<AnomalieModel> anomalieList;

  AnomalieUpdateLoading(this.anomalieList);

  @override
  List<Object> get props => [anomalieList];
}



class AnomalieUpdateLoaded extends AnomalieState {
  final List<AnomalieModel> anomalieList;

  AnomalieUpdateLoaded(this.anomalieList);

  @override
  List<Object> get props => [anomalieList];
}


class AnomalieError extends AnomalieState {
  final String message;

  const AnomalieError(this.message);

  @override
  List<Object> get props => [message];
}
