import 'dart:math';
import 'package:application_rano/blocs/payements/payement_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_rano/blocs/clients/client_bloc.dart';
import 'package:application_rano/blocs/clients/client_state.dart';
import 'package:application_rano/ui/routing/routes.dart';
import 'package:application_rano/blocs/payements/payement_bloc.dart';
import 'package:application_rano/data/models/releves_model.dart';
import 'package:application_rano/data/models/facture_model.dart';
import 'package:application_rano/ui/layouts/app_layout.dart';
import 'package:application_rano/ui/layouts/app_layout.dart';
import 'package:application_rano/blocs/auth/auth_bloc.dart';
import 'package:application_rano/blocs/auth/auth_state.dart';

class DetailCompteurPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFFF5F5F5),
            elevation: 0,
            title: _buildAppBarTitle(context),
            actions: [
              IconButton(
                icon: Icon(Icons.info),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.clientInfo);
                },
              ),
            ],
          ),
          body: AppLayout(
            backgroundColor: Color(0xF7FDFDFD),
            currentIndex: 1,
            authState: authState,
            body: BlocBuilder<ClientBloc, ClientState>(
              builder: (context, state) {
                if (state is ClientLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is ClientLoaded) {
                  return _buildClientData(context, state);
                } else if (state is ClientError) {
                  return Center(child: Text(state.message));
                } else {
                  return SizedBox.shrink();
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBarTitle(BuildContext context) {
    return BlocBuilder<ClientBloc, ClientState>(
      builder: (context, state) {
        if (state is ClientLoaded) {
          final client = state.client;
          final clientName = '${client.nom} ${client.prenom}';
          return Row(
            children: [
              CircleAvatar(
                radius: 30,
                child: Icon(Icons.account_circle, size: 40),
              ),
              SizedBox(width: 20.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clientName,
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ],
          );
        } else {
          return Text('Chargement...');
        }
      },
    );
  }

  Widget _buildClientData(BuildContext context, ClientLoaded state) {
    if (state.client == null) {
      return Center(child: Text('Aucune donnée client disponible'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 20.0),
          _buildReleveCard(context, state.releves),
          // Autres widgets pour afficher les autres informations du client, du compteur, etc.
        ],
      ),
    );
  }

  Widget _buildReleveCard(BuildContext context, List<RelevesModel> releves) {
    if (releves.isEmpty) {
      return Center(child: Text('Aucun relevé disponible'));
    }

    final Random random = Random();

    return Column(
      children: releves.map((releve) {
        // Générer une couleur aléatoire sombre pour l'icône et le titre
        Color randomColor = Color.fromRGBO(
          random.nextInt(100),
          // Plage de valeurs de 0 à 99 pour obtenir des couleurs sombres
          random.nextInt(100),
          random.nextInt(100),
          1,
        );
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
          child: GestureDetector(
            onTap: () {
              // Envoi de l'événement MakePayment au PaymentBloc
              Navigator.pushNamed(context, AppRoutes.facturePayed);
            },
            child: Card(
              color: Color(0xFFFFFFFF), // Couleur de fond plus claire
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: randomColor,
                  child: Icon(Icons.data_usage, color: Colors.white),
                ),
                title: Text(
                  'Relevé du ${releve.dateReleve}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: randomColor,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Text(
                      'Date: ${releve.dateReleve}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Volume: ${releve.volume}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Consommation: ${releve.conso}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
