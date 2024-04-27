import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthEvent {} // Ajoutez cet événement
class CheckIsConnected extends AuthEvent{

}
class LoginRequested extends AuthEvent {
  final String phoneNumber;
  final String password;

  const LoginRequested({required this.phoneNumber, required this.password});

  @override
  List<Object> get props => [phoneNumber, password];
}

// Événement pour indiquer que la synchronisation des données est demandée
class SynchronizeDataRequested extends AuthEvent {
  final String accessToken;

  const SynchronizeDataRequested({required this.accessToken});

  @override
  List<Object> get props => [accessToken];
}

// Événement pour indiquer que la synchronisation avec le serveur est réussie
class LoadingSynchronisationSuccess extends AuthEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'LoadingSynchronisationSuccess';
}
