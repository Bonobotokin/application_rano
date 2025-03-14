import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_rano/blocs/home/home_event.dart';
import 'package:application_rano/blocs/home/home_state.dart';
import 'package:application_rano/data/repositories/home_repository.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository homeRepository;

  HomeBloc({required this.homeRepository}) : super(HomeInitial()) {
    on<LoadHomePageData>((event, emit) async {
      try {
        final data = await homeRepository.fetchHomePageData(event.accessToken);
        emit(HomeLoading(data));
        emit(HomeLoaded(
            data)); // Émettre l'état HomeLoaded avec les nouvelles données
      } catch (e) {
        debugPrint(HomeError('Failed to load data: $e').toString());
        emit(HomeError('Failed to load data: $e'));
      }
    });

    on<RefreshHomePageData>((event, emit) async {
      debugPrint("eto");
      if (state is HomeLoaded) {
        // Récupérer les données actuelles
        final currentData = (state as HomeLoaded).data;
        emit(HomeLoading(
            currentData)); // Émettre un état de chargement en attendant les nouvelles données

        try {
          // Charger les nouvelles données en utilisant le même jeton d'accès ou tout autre logique de rafraîchissement nécessaire
          final refreshedData =
              await homeRepository.fetchHomePageData(event.accessToken);
          emit(HomeLoaded(
              refreshedData)); // Émettre l'état HomeLoaded avec les nouvelles données rafraîchies
        } catch (e) {
          debugPrint(HomeError('Failed to refresh data: $e').toString());
          emit(HomeError('Failed to refresh data: $e'));
          // Éventuellement, vous pouvez émettre un état d'erreur en cas d'échec du rafraîchissement
        }
      }
    });
  }
}
