import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:application_rano/data/services/AppInitializer.dart';
import 'package:application_rano/blocs/splash/splash_bloc.dart';
import 'package:application_rano/ui/views/splash_screen.dart';
import 'package:application_rano/ui/routing/routes.dart';
import 'package:application_rano/data/services/config/api_configue.dart';
import 'package:application_rano/data/services/config/bloc_config.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializer.initialize();
  final baseUrl = await ApiConfig.determineBaseUrl();
  runApp(MyApp(
    baseUrl: baseUrl,
    blocProviders: createBlocProviders(baseUrl),
  ));
}

class MyApp extends StatelessWidget {
  final String baseUrl;
  final List<BlocProvider> blocProviders;

  const MyApp({super.key, required this.baseUrl, required this.blocProviders});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: blocProviders,
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Agent Relever APK',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: BlocProvider(
          create: (context) => SplashBloc(),
          child: const SplashScreen(),
        ),
        getPages: getAppRoutes(),
      ),
    );
  }
}
