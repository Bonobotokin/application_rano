import 'package:equatable/equatable.dart';

// Classe abstraite pour les événements liés au serveur
abstract class ServerEvent extends Equatable {
  const ServerEvent();
}
class CheckServerStatus extends Equatable {
  final String message;

  const CheckServerStatus(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'CheckServerStatus { message: $message }';
}
class CheckServerStatusEvent extends ServerEvent {
  final String message;

  const CheckServerStatusEvent(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'CheckServerStatusEvent { message: $message }';
}

// Événement pour indiquer que la synchronisation avec le serveur est en cours
class LoadingSynchronisation extends ServerEvent {
  @override
  List<Object?> get props => [];

  @override
  String toString() => 'LoadingSynchronisation';
}


