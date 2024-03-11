// home_event.dart
import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

// Ajoutez cette classe
class RefreshHomePageData extends HomeEvent {
  final String accessToken;

  const RefreshHomePageData({required this.accessToken});

  @override
  List<Object> get props => [accessToken];
}

class LoadHomePageData extends HomeEvent {
  final String accessToken;

  const LoadHomePageData({required this.accessToken});

  @override
  List<Object> get props => [accessToken];
}
