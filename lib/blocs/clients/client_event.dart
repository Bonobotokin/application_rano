import 'package:equatable/equatable.dart';

abstract class ClientEvent extends Equatable {
  const ClientEvent();

  @override
  List<Object> get props => [];
}

class LoadClients extends ClientEvent {
  final String accessToken;
  final int numCompteur;

  const LoadClients({required this.accessToken,required this.numCompteur});

  @override
  List<Object> get props => [accessToken];
}

class FetchClientData extends ClientEvent {
  const FetchClientData();

  @override
  List<Object> get props => [];
}
