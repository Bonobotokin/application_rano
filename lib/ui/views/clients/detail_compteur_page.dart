import 'dart:math';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_rano/blocs/clients/client_bloc.dart';
import 'package:application_rano/blocs/clients/client_state.dart';
import 'package:application_rano/ui/routing/routes.dart';
import 'package:application_rano/blocs/payements/payement_bloc.dart';
import 'package:application_rano/blocs/payements/payement_event.dart';
import 'package:application_rano/data/models/releves_model.dart';
import 'package:application_rano/ui/layouts/app_layout.dart';
import 'package:application_rano/blocs/auth/auth_bloc.dart';
import 'package:application_rano/blocs/auth/auth_state.dart';
import 'package:application_rano/ui/shared/DateFormatter.dart';
import 'package:path_provider/path_provider.dart';

class DetailCompteurPage extends StatelessWidget {
  const DetailCompteurPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFF5F5F5),
            elevation: 0,
            title: _buildAppBarTitle(context),
            actions: [
              IconButton(
                icon: const Icon(Icons.info),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.clientInfo);
                },
              ),
            ],
          ),
          body: AppLayout(
            backgroundColor: const Color(0xF7FDFDFD),
            currentIndex: 1,
            authState: authState,
            body: BlocBuilder<ClientBloc, ClientState>(
              builder: (context, state) {
                if (state is ClientLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ClientLoaded) {
                  return _buildClientData(context, state, authState);
                } else if (state is ClientError) {
                  return Center(child: Text(state.message));
                } else {
                  return const SizedBox.shrink();
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
          final clientName = client.nom;
          return Row(
            children: [
              const CircleAvatar(
                radius: 20,
                child: Icon(Icons.account_circle, size: 40),
              ),
              const SizedBox(width: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clientName,
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

  Widget _buildClientData(BuildContext context, ClientLoaded state,
      AuthState authState) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20.0),
          _buildReleveCard(context, state.releves, authState),
          // Other widgets to display other client information, meter information, etc.
        ],
      ),
    );
  }

  Widget _buildReleveCard(BuildContext context, List<RelevesModel> releves, AuthState authState) {
    if (releves.isEmpty) {
      return const Center(child: Text('Aucun relevé disponible'));
    }

    final Random random = Random();

    // Trier les relevés par état de facture (Impayé d'abord)
    releves.sort((a, b) {
      if (a.etatFacture == 'Impayé' && b.etatFacture != 'Impayé') {
        return -1; // a est avant b
      } else if (a.etatFacture != 'Impayé' && b.etatFacture == 'Impayé') {
        return 1; // b est avant a
      } else {
        return 0; // Pas de changement dans l'ordre
      }
    });

    return Column(
      children: releves.map((releve) {
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
              if (authState is AuthSuccess) {
                BlocProvider.of<PaymentBloc>(context).add(LoadPayment(
                    accessToken: authState.userInfo.lastToken ?? '',
                    relevecompteurId: releve.idReleve ?? 0,
                    numCompteur: releve.compteurId,
                    date: releve.dateReleve
                ));
                Navigator.pushNamed(context, AppRoutes.facturePayed);
              }
            },
            child: Card(
              color: const Color(0xFFFFFFFF),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    child: _buildReleveLeading(context, releve, randomColor),
                  ),
                  Expanded( // Ajout de l'Expanded autour du ListTile
                    child: ListTile(
                      title: Text(
                        'Relevé du ${DateFormatter.formatFrenchDate(releve.dateReleve)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: randomColor,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            'Date: ${releve.dateReleve}',
                            style: const TextStyle(fontSize: 16),
                          ),
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
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: Colors.purple[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }


  Widget _buildReleveLeading(BuildContext context, RelevesModel releve, Color randomColor) {
    if (releve.imageCompteur != null && releve.imageCompteur.isNotEmpty && File(releve.imageCompteur).existsSync()) {
      return GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                child: Image.file(
                  File(releve.imageCompteur),
                  fit: BoxFit.contain,
                ),
              );
            },
          );
        },
        child: Image.file(
          File(releve.imageCompteur),
          width: 56,
          height: 56,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return CircleAvatar(
        backgroundColor: randomColor,
        child: const Icon(Icons.data_usage, color: Colors.white),
      );
    }
  }
}
