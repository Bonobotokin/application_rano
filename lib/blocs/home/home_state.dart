import 'package:equatable/equatable.dart';
import 'package:application_rano/data/models/home_model.dart'; // Importez votre modèle HomeModel

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {
  final HomeModel data; // Utilisez HomeModel au lieu de String

  const HomeLoading(this.data);

  @override
  List<Object> get props => [data];
}

class HomeLoaded extends HomeState {
  final HomeModel data; // Utilisez HomeModel au lieu de String

  const HomeLoaded(this.data);

  @override
  List<Object> get props => [data];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}
