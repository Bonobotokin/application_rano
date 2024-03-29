import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_rano/blocs/auth/auth_event.dart';
import 'package:application_rano/blocs/auth/auth_state.dart';
import 'package:application_rano/data/repositories/auth_repository.dart';
import 'package:application_rano/data/models/user_info.dart'; // Importez le modèle UserInfo
import 'package:application_rano/data/services/saveData/save_data_service_locale.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  String? accessToken;
  final UserInfo? userInfo;
  final SaveDataRepositoryLocale saveDataRepositoryLocale =
      SaveDataRepositoryLocale();

  AuthBloc({required this.authRepository, this.userInfo})
      : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      try {
        emit(AuthLoading());
        final user =
            await authRepository.login(event.phoneNumber, event.password);

        if (user != null) {
          final accessToken = user.lastToken;
          final homeData = await authRepository.fetchHomeDataFromEndpoint(accessToken);

          if (homeData['data'] == 0) {
            emit(AuthSuccess(userInfo: UserInfo.fromUser(user)));
          } else {
            await _processMissionsData(accessToken);
          }

          emit(AuthSuccess(userInfo: UserInfo.fromUser(user)));

        } else {
          print("Échec de l'authentification");
          emit(AuthFailure(error: "Échec de l'authentification"));
        }
      } catch (error) {
        print("Erreur lors de la connexion: $error");
        emit(AuthFailure(error: "Erreur lors de la connexion: $error"));
      }
    });
  }

  @override
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    if (event is LoginRequested) {
      yield* _mapLoginRequestedToState(event);
    }
  }

  Stream<AuthState> _mapLoginRequestedToState(LoginRequested event) async* {
    try {
      yield AuthLoading();

      final user =
          await authRepository.login(event.phoneNumber, event.password);
      if (user != null) {
        emit(AuthSuccess(userInfo: UserInfo.fromUser(user)));
      } else {
        yield AuthFailure(error: "Échec de l'authentification");
      }
    } catch (e) {
      yield AuthFailure(error: "Échec de l'authentification: $e");
    }
  }

  Future<void> _processMissionsData(String? accessToken) async {
    final missionsData = await authRepository.fetchMissionsDataFromEndpoint(accessToken);

    for (var mission in missionsData['compteurs_liste']) {
      final int numCompteur = int.parse(mission['num_compteur']);
      final clientDetails = await authRepository.fetchDataClientDetails(numCompteur, accessToken);

      await Future.wait([
        saveDataRepositoryLocale.saveCompteurDetailsRelever(clientDetails['compteur']),
        saveDataRepositoryLocale.saveContraDetailsRelever(clientDetails['contrat']),
        saveDataRepositoryLocale.saveClientDetailsRelever(clientDetails['client']),
        saveDataRepositoryLocale.saveReleverDetailsRelever(clientDetails['releves'])
      ]);
    }
  }
}
