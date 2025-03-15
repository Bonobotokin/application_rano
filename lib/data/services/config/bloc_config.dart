import 'package:application_rano/blocs/anomalies/anomalie_bloc.dart';
import 'package:application_rano/blocs/commentaire/commentaire_bloc.dart';
import 'package:application_rano/blocs/factures/facture_bloc.dart';
import 'package:application_rano/blocs/send_data/send_data_bloc.dart';
import 'package:application_rano/data/repositories/anomalie/anomalie_repository.dart';
import 'package:application_rano/data/repositories/relever_repository.dart';
import 'package:application_rano/ui/views/anomalie/commentaire_page.dart';
import 'package:application_rano/ui/views/factures/client_list_page.dart';
import 'package:application_rano/ui/views/home_page.dart';
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
import 'package:application_rano/data/repositories/local/facture_local_repository.dart';
import '../../../ui/views/anomalie/anomalie_page.dart';
import 'package:application_rano/ui/views/factures/client_list_page.dart';
import 'package:application_rano/data/repositories/commentaire/CommentaireRepositoryLocale.dart';

List<BlocProvider> createBlocProviders(String baseUrl) {
  return [
    BlocProvider<ServerBloc>(
      create: (context) => ServerBloc(NiADatabases()),
    ),
    BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(
        authRepository: AuthRepository(baseUrl: baseUrl),
      ),
    ),
    BlocProvider<SendDataBloc>(
      create: (context) => SendDataBloc(),
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
      child: const DetailCompteurPage(),
    ),
    BlocProvider<PaymentBloc>(
      create: (context) => PaymentBloc(
          factureLocalRepository: FactureLocalRepository(), 
          clientRepository: ClientRepository(baseUrl: baseUrl), 
          releverRepository: ReleverRepository()),
      // child: ,
    ),
    BlocProvider<AnomalieBLoc>(
        create: (context) => AnomalieBLoc(
            anomalieRepository: AnomalieRepository(baseUrl: baseUrl)),
      child: const AnomaliePage(),
    ),
    BlocProvider<FactureBloc>(
      create: (context) => FactureBloc(
          clientRepository: ClientRepository(baseUrl: baseUrl)),
      child: ClientListPage(),
    ),

    BlocProvider<CommentaireBLoc>(
        create: (context) => CommentaireBLoc(
            commentaireRepositoryLocale: CommentaireRepositoryLocale()),
        child: CommentairePage(),
    ),

  ];
}
