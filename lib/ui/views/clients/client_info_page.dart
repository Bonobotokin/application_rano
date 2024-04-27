import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_rano/blocs/clients/client_bloc.dart';
import 'package:application_rano/blocs/clients/client_state.dart';
import 'package:application_rano/data/models/client_model.dart';
import 'package:application_rano/data/models/compteur_model.dart';
import 'package:application_rano/data/models/contrat_model.dart';

class ClientInfoPage extends StatefulWidget {
  const ClientInfoPage({super.key});

  @override
  _ClientInfoPageState createState() => _ClientInfoPageState();
}

class _ClientInfoPageState extends State<ClientInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: const Text('Informations du client'),
      ),
      body: Center(
        child: BlocBuilder<ClientBloc, ClientState>(
          builder: (context, state) {
            if (state is ClientLoaded) {
              final client = state.client;
              final compteur = state.compteur.first;
              final contrat = state.contrat;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProfileHeader(client),
                    const SizedBox(height: 24.0),
                    _buildInfoCard(
                        'Coordonnées', _buildContactInfo(client), Colors.blue),
                    const SizedBox(height: 24.0),
                    _buildInfoCard('Détails du Contrat',
                        _buildContractInfo(contrat), Colors.green),
                    const SizedBox(height: 24.0),
                    _buildInfoCard('Détails du Compteur',
                        _buildMeterInfo(compteur), Colors.orange),
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
  }

  Widget _buildProfileHeader(ClientModel client) {
    Widget verifiedText = client.actif == true
        ? const Text('Actif', style: TextStyle(color: Colors.blueAccent))
        : const Text('Non actif', style: TextStyle(color: Colors.grey));

    return Column(
      children: [
        const CircleAvatar(
          radius: 80.0,
          backgroundImage: AssetImage('assets/images/images.jpeg'),
        ),
        const SizedBox(height: 16.0),
        Text(
          '${client.nom} ${client.prenom}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28.0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8.0),
        const Text(
          'Signbox software',
          style: TextStyle(fontSize: 18.0),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.blueAccent),
            const SizedBox(width: 8.0),
            verifiedText,
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, Widget content, Color color) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(ClientModel client) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContactDetail(Icons.phone, client.telephone_1),
        const SizedBox(height: 8.0),
        _buildContactDetail(Icons.location_on, client.adresse),
      ],
    );
  }

  Widget _buildContractInfo(ContratModel contrat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContractDetail('Numero', contrat.numeroContrat),
        _buildContractDetail('Debut', contrat.dateDebut),
        _buildContractDetail('Fin', contrat.dateFin ?? ''),
        _buildContractDetail('Adresse', contrat.adresseContrat),
        _buildContractDetail('Pays', contrat.paysContrat),
      ],
    );
  }

  Widget _buildMeterInfo(CompteurModel compteur) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMeterDetail('Marque', compteur.marque),
        _buildMeterDetail('Modèle', compteur.modele),
      ],
    );
  }

  Widget _buildMeterDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 18.0, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildContractDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 18.0, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildContactDetail(IconData icon, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12.0),
          Text(
            detail,
            style: TextStyle(fontSize: 18.0, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
