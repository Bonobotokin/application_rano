import 'package:equatable/equatable.dart';
import 'package:application_rano/data/models/user_info.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class Authenticated extends AuthState {
  final UserInfo userInfo;

  const Authenticated(this.userInfo);

  @override
  List<Object> get props => [userInfo];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserInfo userInfo;

  const AuthSuccess({required this.userInfo});

  @override
  List<Object> get props => [userInfo];
}

class AuthFailure extends AuthState {
  final String error;

  const AuthFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class LoadingSynchronisationSuccessState extends AuthState {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'LoadingSynchronisationSuccessState';
}

class AuthSyncInProgress extends AuthState {
  final double progress;

  AuthSyncInProgress(this.progress);
}

class AuthSyncSuccess extends AuthState {}

class AuthSyncError extends AuthState {
  final String errorMessage;

  AuthSyncError(this.errorMessage);
}

class LoadSendDataLocal extends AuthState {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'envoie de donner en cours';
}

class LoadSendDataLocalEnd extends AuthState {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'envoie de donner Terminer';
}


class LoadingSynchronisationInProgress extends AuthState {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'Synchronisation en cours';
}

class LoadingSynchronisationEnd extends AuthState {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'Synchronisation en Terminer';
}