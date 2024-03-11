import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthEvent {} // Ajoutez cet événement
class LoginRequested extends AuthEvent {
  final String phoneNumber;
  final String password;

  const LoginRequested({required this.phoneNumber, required this.password});

  @override
  List<Object> get props => [phoneNumber, password];
}
