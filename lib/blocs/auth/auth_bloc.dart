import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_rano/blocs/auth/auth_event.dart';
import 'package:application_rano/blocs/auth/auth_state.dart';
import 'package:application_rano/data/repositories/auth_repository.dart';
import 'package:application_rano/data/models/user_info.dart';
import 'package:application_rano/data/services/saveData/save_data_service_locale.dart';
import 'package:application_rano/data/services/synchronisation/sync_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  late final SyncService syncService;

  String? accessToken;
  final UserInfo? userInfo;
  final SaveDataRepositoryLocale saveDataRepositoryLocale = SaveDataRepositoryLocale();

  AuthBloc({required this.authRepository, this.userInfo})
      : super(AuthInitial()) {
    syncService = SyncService(authRepository: authRepository);
    on<LoginRequested>((event, emit) async {
      try {
        emit(AuthLoading());
        final user = await authRepository.login(event.phoneNumber, event.password);

        if (user != null) {
          accessToken = user.lastToken;

          // Commencez la synchronisation
          _startSync();

          await syncService.synchronizeLocalData(accessToken!);

          final homeData = await authRepository.fetchHomeDataFromEndpoint(accessToken);

          if (homeData['data'] == 0) {
            emit(AuthSuccess(userInfo: UserInfo.fromUser(user)));
          } else {
            print('Eto...');
            // Attendre la fin de la synchronisation
            await _onLoadingSynchronisation(accessToken);
          }

          emit(AuthSuccess(userInfo: UserInfo.fromUser(user)));
        } else {
          print("Échec de l'authentification");
          emit(const AuthFailure(error: "Échec de l'authentification"));
        }
      } catch (error) {
        print("Erreur lors de la connexion: $error");
        emit(AuthFailure(error: "Erreur lors de la connexion: $error"));
      }
    });
  }

  void _startSync() async {
    try {
      // Commencez la synchronisation
      emit(AuthSyncInProgress(0.0));

      // Exemple de progression de synchronisation
      for (int i = 0; i <= 100; i += 10) {
        // Supposez que vous mettiez à jour la progression de la synchronisation ici
        await Future.delayed(const Duration(seconds: 1)); // Simulez un travail de synchronisation
        emit(AuthSyncInProgress(i / 100)); // Mettez à jour la progression de la synchronisation
      }

      // Synchronisation réussie
      emit(AuthSyncSuccess());
    } catch (e) {
      // Gérer les erreurs de synchronisation
      emit(AuthSyncError('Erreur de synchronisation: $e'));
    }
  }

  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    if (event is LoginRequested) {
      yield* _mapLoginRequestedToState(event);
    } else if (event is LoadingSynchronisationSuccess) {
      yield LoadingSynchronisationSuccessState(); // Mettez à jour l'état pour indiquer que la synchronisation est réussie
    }
  }

  Stream<AuthState> _mapLoginRequestedToState(LoginRequested event) async* {
    try {
      yield AuthLoading();

      final user = await authRepository.login(event.phoneNumber, event.password);
      if (user != null) {
        emit(AuthSuccess(userInfo: UserInfo.fromUser(user)));
      } else {
        yield const AuthFailure(error: "Échec de l'authentification");
      }
    } catch (e) {
      yield AuthFailure(error: "Échec de l'authentification: $e");
    }
  }

  // Méthode pour la synchronisation des données avec le serveur
  Future<void> _onLoadingSynchronisation(String? accessToken) async {
    try {
      await syncService.syncDataWithServer(accessToken);
    } catch (error) {
      print('Erreur lors de la synchronisation: $error');
    }
  }
}
