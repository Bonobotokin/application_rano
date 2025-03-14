import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_rano/blocs/auth/auth_bloc.dart';
import 'package:application_rano/blocs/auth/auth_state.dart';
import 'package:application_rano/blocs/factures/facture_bloc.dart';
import 'package:application_rano/blocs/factures/facture_event.dart';
import 'package:application_rano/blocs/factures/facture_state.dart';
import 'package:application_rano/ui/layouts/app_layout.dart';
import '../../../blocs/payements/payement_bloc.dart';
import '../../../blocs/payements/payement_event.dart';
import '../../../data/models/releves_model.dart';
import '../../routing/routes.dart';
import '../../shared/DateFormatter.dart';
import 'client_list_page.dart';

class ClientFactureList extends StatefulWidget {
  const ClientFactureList({super.key});

  @override
  ClientFactureListState createState() => ClientFactureListState();
}

class ClientFactureListState extends State<ClientFactureList> {

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFF5F5F5),
            elevation: 0,
            title: _buildAppBarTitle(context),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                BlocProvider.of<FactureBloc>(context)
                    .add(const LoadClientFacture(accessToken: ''));
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ClientListPage()));
              },
            ),
          ),
          body: AppLayout(
            backgroundColor: const Color(0xF7FDFDFD),
            currentIndex: 3,
            authState: authState,
            body: BlocBuilder<FactureBloc, FactureState>(
              builder: (context, state) {
                if (state is LoadingPage) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is FactureClientLoaded) {
                  // Tri des relevés en fonction de l'état de la facture
                  List<RelevesModel> sortedReleves = state.releves.toList();
                  sortedReleves.sort((a, b) {
                    if (a.etatFacture == 'Impayé' && b.etatFacture != 'Impayé') {
                      return -1; // Mettre les factures impayées en premier
                    } else if (a.etatFacture != 'Impayé' && b.etatFacture == 'Impayé') {
                      return 1;
                    } else {
                      return 0;
                    }
                  });
                  return _buildClientListWidget(context, sortedReleves, authState);
                } else if (state is FactureFailure) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error,
                          size: 60,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Aucune donnée trouvée',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBarTitle(BuildContext context) {
    return BlocBuilder<FactureBloc, FactureState>(
      builder: (context, state) {
        if (state is FactureClientLoaded) {
          final client = state.client;
          final clientName = client.nom.length >= 10
              ? client.nom.substring(client.nom.length - 10)
              : client.nom;

          return Row(
            children: [
              const SizedBox(width: 20.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Liste Facture de $clientName',
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ],
          );
        } else {
          return const Text('Chargement...');
        }
      },
    );
  }

  Widget _buildClientListWidget(
      BuildContext context, List<RelevesModel> releves, AuthState authState) {
    if (releves.isEmpty) {
      return const Center(child: Text('Aucun relevé disponible'));
    }

    final Random random = Random();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: releves.map((releve) {
          // Générer une couleur aléatoire sombre pour l'icône et le titre
          Color randomColor = Color.fromRGBO(
            random.nextInt(100),
            random.nextInt(100),
            random.nextInt(100),
            1,
          );
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
            child: GestureDetector(
              onTap: () {
                // Envoi de l'événement MakePayment au PaymentBloc
                if (authState is AuthSuccess) {
                  BlocProvider.of<PaymentBloc>(context).add(LoadPayment(
                      accessToken: authState.userInfo.lastToken ?? '',
                      relevecompteurId: releve.id ?? 0,
                      numCompteur: releve.compteurId,
                      date: releve.dateReleve));
                  Navigator.pushNamed(context, AppRoutes.facturePayed);
                }
              },
              child: Card(
                color: const Color(0xFFFFFFFF), // Couleur de fond plus claire
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: randomColor,
                    child: const Icon(Icons.data_usage, color: Colors.white),
                  ),
                  title: Text(
                    'Facture du ${DateFormatter.formatFrenchDate(releve.dateReleve)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: randomColor,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Volume: ${releve.volume}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Consommation: ${releve.conso}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Etat du facture : ${releve.etatFacture}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold, // Pour le texte en gras
                          fontStyle: FontStyle.italic, // Pour le texte en italique
                          color: Colors.purple[900], // Utilisation de la teinte violette-indigo
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
