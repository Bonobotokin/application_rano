import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_rano/blocs/server/server_bloc.dart';
import 'package:application_rano/blocs/auth/auth_bloc.dart';
import 'package:application_rano/blocs/home/home_bloc.dart';
import 'package:application_rano/blocs/missions/missions_bloc.dart';
import 'package:application_rano/blocs/clients/client_bloc.dart';
import 'package:application_rano/data/repositories/auth_repository.dart';
import 'package:application_rano/data/repositories/home_repository.dart';
import 'package:application_rano/data/repositories/missions_repository.dart';
import 'package:application_rano/data/repositories/client_repository.dart';
import 'package:application_rano/blocs/payements/payement_bloc.dart';
import 'package:application_rano/ui/views/clients/detail_compteur_page.dart';
import 'package:application_rano/data/services/databases/nia_databases.dart';
import 'package:application_rano/data/services/sync_service.dart'; // Importer le SyncService

List<BlocProvider> createBlocProviders(String baseUrl) {
  return [
    BlocProvider<ServerBloc>(
      create: (context) => ServerBloc(NiADatabases(), SyncService()),
    ),
    BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(
        authRepository: AuthRepository(baseUrl: baseUrl),
      ),
    ),
    BlocProvider<HomeBloc>(
      create: (context) => HomeBloc(
        homeRepository: HomeRepository(baseUrl: baseUrl),
      ),
    ),
    BlocProvider<MissionsBloc>(
      create: (context) => MissionsBloc(
        missionsRepository: MissionsRepository(baseUrl: baseUrl),
      ),
    ),
    BlocProvider<ClientBloc>(
      create: (context) => ClientBloc(
        clientRepository: ClientRepository(baseUrl: baseUrl),
      ),
      child: DetailCompteurPage(),
    ),
    BlocProvider<PaymentBloc>(
      create: (context) => PaymentBloc(),
      child: DetailCompteurPage(),
    ),
  ];
}
