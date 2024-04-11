import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_rano/blocs/auth/auth_bloc.dart';
import 'package:application_rano/blocs/auth/auth_state.dart';
import 'package:application_rano/blocs/anomalies/anomalie_bloc.dart';
import 'package:application_rano/blocs/anomalies/anomalie_state.dart';
import 'package:application_rano/data/models/anomalie_model.dart';
import 'package:application_rano/ui/layouts/app_layout.dart';

class AnomaliePage extends StatefulWidget {
  const AnomaliePage({super.key});

  @override
  _AnomaliePageState createState() => _AnomaliePageState();
}

class _AnomaliePageState extends State<AnomaliePage> {
  String _searchText = '';
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return AppLayout(
          backgroundColor: const Color(0xFFF5F5F5),
          currentIndex: 1,
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
                      "Anomalie",
                      style: TextStyle(
                        color: Color(0xdd2e3131),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              BlocBuilder<AnomalieBLoc, AnomalieState>(
                builder: (context, state) {
                  if (state is AnomalieLoading) {
                    return _buildMissionListWidget(state.anomalie, authState);
                  } else if (state is AnomalieLoaded) {
                    return _buildMissionListWidget(state.anomalie, authState);
                  } else if (state is AnomalieError) {
                    return Center(child: Text('Erreur: ${state.message}'));
                  }  else {
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

  Widget _buildMissionListWidget(
      List<AnomalieModel> anomalie, AuthState authState) {
    anomalie.sort((a, b) {
      final aStatut = a.status ?? 0;
      final bStatut = b.status ?? 0;
      return aStatut.compareTo(bStatut);
    });

    final filteredMissions = _searchText.isEmpty
        ? anomalie
        : anomalie
        .where((anomalie) =>
    (anomalie.typeMc?.toLowerCase() ?? '')
        .contains(_searchText.toLowerCase()) ||
        (anomalie.dateDeclaration?.toLowerCase() ?? '')
            .contains(_searchText.toLowerCase()))
        .toList();

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(0.0),
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
                padding: const EdgeInsets.symmetric(horizontal: 0),
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
          if (filteredMissions.isEmpty)
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
                itemCount: filteredMissions.length,
                itemBuilder: (context, index) {
                  final mission = filteredMissions[index];
                  return _buildMissionTile(context, mission, authState);
                },
              ),
            ),
        ],
      ),
    );
  }

  // Construire une tuile pour chaque mission
  Widget _buildMissionTile(
      BuildContext context, AnomalieModel anomalie, AuthState authState) {
    String Status;
    if(anomalie.status == 0 ) {
      Status = "Non Traiter";
    }
    else if (anomalie.status == 0 ) {
      Status = "En Cours";
    }
    else{
      Status = "Reussit";
    }
    Color cardColor =
    anomalie.status == 1 ? const Color(0xFFFFFFFF) : const Color(0xFFBBDEFB);
    Color btnColor =
    anomalie.status == 1 ? const Color(0xFFEEE9E9) : const Color(0xFFBBDEFB);
    String buttonText = anomalie.status == 1 ? 'Modifier' : 'Ajouter';


    return GestureDetector(
      onTap: () {

      },
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: cardColor,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          title: Row(
            children: [
              Icon(Icons.warning_amber,
                  color: anomalie.status == 1 ? Colors.grey : Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Anomalie : ${anomalie.idMc}',
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
              Text('Type: ${anomalie.typeMc}'),
              Text('Longitude: ${anomalie.descriptionMc}'),
              Text('Altitude: ${anomalie.descriptionMc}'),
              Text('Description: ${anomalie.descriptionMc}'),
              Text('Declarant: ${anomalie.clientDeclare}'),
              Text('Date: ${anomalie.dateDeclaration}'),
              Text('Etat: $Status' ,
                style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),),

            ],
          ),
        ),

      ),
    );
  }

}
