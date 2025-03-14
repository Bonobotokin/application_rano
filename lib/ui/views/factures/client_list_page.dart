import 'package:application_rano/blocs/factures/facture_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_rano/data/models/client_model.dart';
import 'package:application_rano/blocs/auth/auth_bloc.dart';
import 'package:application_rano/blocs/auth/auth_state.dart';
import 'package:application_rano/blocs/factures/facture_bloc.dart';
import 'package:application_rano/blocs/factures/facture_state.dart';
import 'package:application_rano/ui/layouts/app_layout.dart';
import 'package:get/get.dart';
import '../../../data/models/compteur_model.dart';
import '../../routing/routes.dart';

class ClientListPage extends StatefulWidget {
  const ClientListPage({super.key});

  @override
  ClientListPageState createState() => ClientListPageState();
}

class ClientListPageState extends State<ClientListPage> {
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return AppLayout(
          backgroundColor: const Color(0xFFF5F5F5),
          currentIndex: 3,
          authState: authState,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(20.0),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Liste des clients",
                      style: TextStyle(
                        color: Color(0xdd2e3131),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              BlocBuilder<FactureBloc, FactureState>(
                builder: (context, state) {
                  if(state is LoadingPage){
                    return const Center(child: CircularProgressIndicator());
                  }
                  else if (state is FactureLoading) {
                    return _buildClientListWidget(state.clients, state.compteurs, state.nombreEtatImpaye, state.nombreEtatPaye, authState);
                  }
                  if(state is FactureLoaded) {
                    return _buildClientListWidget(state.clients, state.compteurs, state.nombreEtatImpaye, state.nombreEtatPaye, authState);
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
                    return Container();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClientListWidget(List<ClientModel> clients, List<CompteurModel> compteurs, List<int> releves, List<int> releve, AuthState authState) {
    // Filtrer les clients, compteurs et relevés ensemble
    final filteredData = clients.asMap().entries.where((entry) {
      final client = entry.value;
      return _searchText.isEmpty ||
          (client.nom.toLowerCase()).contains(_searchText.toLowerCase()) ||
          (client.prenom.toLowerCase()).contains(_searchText.toLowerCase()) ||
          (client.adresse.toLowerCase()).contains(_searchText.toLowerCase());
    }).map((entry) {
      final index = entry.key;
      return {
        'client': clients[index],
        'compteur': compteurs[index],
        'releveImpaye': releves[index],
        'relevePaye': releve[index],
      };
    }).toList();

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey, width: 1),
                color: const Color(0xFFEEEEEE),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: 'Rechercher...',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchText = value;
                    });
                  },
                ),
              ),
            ),
          ),
          if (filteredData.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_rounded,
                    size: 60,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Aucun résultat trouvé',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: filteredData.length,
                itemBuilder: (context, index) {
                  final data = filteredData[index];
                  final client = data['client'] as ClientModel;
                  final compteur = data['compteur'] as CompteurModel;
                  final nombreEtatImpaye = data['releveImpaye'] as int;
                  final nombreEtatPaye = data['relevePaye'] as int;
                  return _buildClientTile(context, client, compteur, nombreEtatImpaye, nombreEtatPaye, authState);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildClientTile(BuildContext context, ClientModel client, CompteurModel compteur, int nombreEtatImpaye, int nombreEtatPaye, authState) {
    return GestureDetector(
      onTap: () {
        BlocProvider.of<FactureBloc>(context).add(LoadClientInvoices(
            accessToken: authState.userInfo.lastToken ?? '',
            numCompteur: client.id ?? 0));
        Get.toNamed(AppRoutes.listeFactureClient, arguments: compteur.id);
      },
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          title: Row(
            children: [
              const Icon(Icons.account_circle, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                '${client.nom} ${client.prenom}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text('Adresse: ${client.adresse}'),
              Text('Téléphone: ${client.telephone_1 == "" ? "pas de numero" : client.telephone_1}'),
              Text('Contrat: ${client.actif == 1 ? "Actif" : "Desactivé"}'),  // Ajout de la condition pour afficher l'état du contrat
              Text('Numero compteur: ${compteur.id}'),
              const SizedBox(height: 10),
              Text('Totale facture: ${nombreEtatImpaye + nombreEtatPaye}'),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Facture impayées:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red, // Couleur pour les factures impayées
                        ),
                      ),
                      Text('$nombreEtatImpaye'),
                    ],
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Facture payées:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green, // Couleur pour les factures payées
                        ),
                      ),
                      Text('$nombreEtatPaye'),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // Vous pouvez ajouter d'autres actions ici si nécessaire
        ),
      ),
    );
  }
}
