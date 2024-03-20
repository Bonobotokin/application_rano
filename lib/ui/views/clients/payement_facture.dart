import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_rano/blocs/auth/auth_bloc.dart';
import 'package:application_rano/blocs/auth/auth_state.dart';
import 'package:application_rano/blocs/auth/auth_bloc.dart';
import 'package:application_rano/blocs/auth/auth_state.dart';
import 'package:application_rano/blocs/payements/payement_bloc.dart';
import 'package:application_rano/blocs/payements/payement_event.dart';
import 'package:application_rano/blocs/payements/payement_state.dart';
import 'package:application_rano/ui/layouts/app_layout.dart';

import '../../widgets/PaymentFormPopup.dart';

class PaymentFacture extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue,
            elevation: 0,
            title: Text('Paiement des factures'),
          ),
          body: AppLayout(
            backgroundColor: Color(0xFFF5F5F5),
            currentIndex: 1,
            authState: authState,
            body: BlocBuilder<PaymentBloc, PaymentState>(
              builder: (context, state) {
                final paymentBloc = BlocProvider.of<PaymentBloc>(context);
                if (state is PayementLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is PayementLoaded) {
                  // Récupérer les données nécessaires pour charger le paiement
                  final specificDateReleves = state.specificDateReleves;
                  final previousDateReleves = state.previousDateReleves;
                  final numCompteur = state.factures.numCompteur;
                  final date = state.factures.dateFacture; // Ou la date que vous souhaitez utiliser

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(context, state),
                        _buildOrderDetails(context, state),
                        buildTotal(context, state),
                        buildPayButton(context, state, authState),
                      ],
                    ),
                  );
                } else if (state is PaymentFailure) {
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

  Widget _buildHeader(BuildContext context, PayementLoaded state) {
    final client = state.client;
    final facture = state.factures;
    final clientName = '${client.nom}';
    final clientNum = '${facture.numFacture}';
    return Container(
      color: Colors.blue,
      padding: EdgeInsets.all(20.0),
      child: Center(
        child: Text(
          'Facture de $clientName - $clientNum',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context, PayementLoaded state) {
    final specificDateReleves = state.specificDateReleves;
    final previousDateReleves = state.previousDateReleves;

    return Container(
      padding: EdgeInsets.all(20.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Détails de la facture',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var releve in specificDateReleves)
                buildOrderItem(context, releve.dateReleve, releve.volume.toString(), releve.conso.toString()),
            ],
          ),
          SizedBox(height: 20.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var releve in previousDateReleves)
                buildOrderItem(context, releve.dateReleve, releve.volume.toString(), releve.conso.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildOrderItem(BuildContext context, String item, String sku,  String subtotal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                item,
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            SizedBox(width: 10.0),
            Expanded(
              child: Text(
                'Volume : $sku',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),

        SizedBox(height: 5.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                ' ',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            SizedBox(width: 10.0),
            Expanded(
              child: Text(
                'Consommation : $subtotal',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),

        Divider(),
      ],
    );
  }

  Widget buildTotal(BuildContext context, PayementLoaded state) {
    final factures = state.factures;
    return Container(
      color: Colors.blue,
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: [
          buildTotalRow('Prix par m3', '${factures.tarifM3} Ar'),
          buildTotalRow('Total général (Incl. Taxe)', '${factures.montantTotalTTC} Ar'),
          buildTotalRow('Total', '${factures.totalConsoHT} Ar'),
        ],
      ),
    );
  }

  Widget buildTotalRow(String title, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(amount, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget buildPayButton(BuildContext context, state, authState) {
    return Padding(
        padding: const EdgeInsets.all(20.0),
    child: SizedBox(
    width: double
        .infinity,
      child: ElevatedButton(
        onPressed: () {
          _showFormDialog(context, state, authState);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(vertical: 15.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment, color: Colors.white),
            SizedBox(width: 10.0),
            Text(
              'Payer',
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            ),
          ],
        ),
      ),
    ),
    );
  }


  void _showFormDialog(BuildContext context) {
    TextEditingController _amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Paiement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Montant à payer ${widget.facture.totalConsoHT} Ar :'),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Entrez le montant',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                double amount = double.tryParse(_amountController.text) ?? 0.0;
                if (widget.authState is AuthSuccess) {
                  final paymentBloc = context.read<PaymentBloc>(); // Utiliser context.read pour obtenir le bloc
                  paymentBloc.add(UpdateFacture(
                    idFacture: widget.facture.id,
                    montant: amount,
                  ));
                }
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text('Payer'),
            ),
          ],
        );
      },
    );
  }


}
