import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_rano/blocs/splash/splash_event.dart';
import 'package:application_rano/blocs/splash/splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitialState());

  Stream<SplashState> mapEventToState(SplashEvent event) async* {
    if (event is SetSplash) {
      yield SplashLoadingState();
      try {
        await Future.delayed(const Duration(seconds: 5));
        yield SplashLoadedState();
      } catch (error) {
        yield SplashErrorState(error.toString());
      }
    }
  }
}
