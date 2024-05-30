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
    on<LoginRequested>(_onLoginRequested);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      final user = await authRepository.login(event.phoneNumber, event.password);

      if (user != null) {
        accessToken = user.lastToken;

        // emit(LoadSendDataLocal());
        //   await syncService.synchronizeLocalData(accessToken!);
        // emit(LoadSendDataLocalEnd());
        final homeData = await authRepository.fetchHomeDataFromEndpoint(accessToken);

        if (homeData['data'] == 0) {
          emit(AuthSuccess(userInfo: UserInfo.fromUser(user)));
        } else {
          // emit(LoadingSynchronisationInProgress());
          //   await syncService.syncDataWithServer(accessToken!);
          // emit(LoadingSynchronisationEnd());

          emit(AuthSuccess(userInfo: UserInfo.fromUser(user)));
        }
      } else {
        emit(const AuthFailure(error: "Échec de l'authentification"));
      }
    } catch (error) {
      emit(AuthFailure(error: "Erreur lors de la connexion: $error"));
    }
  }

  Future<void> _onLoadingSynchronisation(String? accessToken) async {
    try {
      await syncService.syncDataWithServer(accessToken);
    } catch (error) {
      print('Erreur lors de la synchronisation: $error');
    }
  }
}
