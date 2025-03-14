import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_rano/blocs/auth/auth_bloc.dart';
import 'package:application_rano/blocs/auth/auth_state.dart';
import 'package:application_rano/blocs/payements/payement_bloc.dart';
import 'package:application_rano/blocs/payements/payement_event.dart';
import 'package:application_rano/blocs/payements/payement_state.dart';
import 'package:application_rano/ui/layouts/app_layout.dart';

class PaymentFacture extends StatelessWidget {
  const PaymentFacture({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue,
            elevation: 0,
            title: const Text('Paiement des factures'),
          ),
          body: AppLayout(
            backgroundColor: const Color(0xFFF5F5F5),
            currentIndex: 3,
            authState: authState,
            body: BlocBuilder<PaymentBloc, PaymentState>(
              builder: (context, state) {
                if (state is PayementLoading) {
                  return _buildLoadingState(context);
                } else if (state is PayementLoaded) {
                  return _buildLoadedState(context, state, authState);
                } else if (state is PaymentFailure) {
                  return Center(child: Text(state.message));
                } else if (state is PaymentSuccess) {
                  return _buildSuccessState(context);
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

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        backgroundColor: Colors.white,
      ),
    );
  }
  Widget _buildSuccessState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 64),
          SizedBox(height: 16),
          Text(
            'Paiement effectué avec succès!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          // TextButton(
          //   onPressed: () {
          //
          //   },
          //   // child: Text('Retour'),
          // ),
        ],
      ),
    );
  }




  Widget _buildLoadedState(BuildContext context, PayementLoaded state, AuthState authState) {
    return ListView(
      children: [
        _buildHeader(context, state),
        _buildOrderDetails(context, state),
        buildDetails(context, state),
        buildTotal(context, state),
        buildPayButton(context, state, authState),
        SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, PayementLoaded state) {
    final client = state.client;
    final facture = state.factures;
    final clientName = client.nom;
    final clientNum = facture.numFacture;
    return Container(
      color: Colors.blue,
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Text(
          'Facture de $clientName - $clientNum',
          style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context, PayementLoaded state) {
    final specificDateReleves = state.specificDateReleves;
    final previousDateReleves = state.previousDateReleves;

    return Container(
      padding: const EdgeInsets.all(20.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Détails de la facture',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  state.factures.statut,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var releve in specificDateReleves)
                buildOrderItem(context, releve.dateReleve, releve.volume.toString(), releve.conso.toString()),
            ],
          ),
          const SizedBox(height: 20.0),
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

  Widget buildOrderItem(BuildContext context, String item, String sku, String subtotal) {
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
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                'Volume : $sku',
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Text(
                ' ',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                'Consommation : $subtotal',
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }

  Widget buildDetails(BuildContext context, PayementLoaded state) {
    final payment = state.payment;
    return ExpansionTile(
      title: const Text('Détails du paiement'),
      children: [
        Row(
          children: [
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                'ID: ${payment.relevecompteurId} / Date : ${payment.datePaiement}',
                style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Paiement: ${payment.paiement} Ar',
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildTotal(BuildContext context, PayementLoaded state) {
    final factures = state.factures;
    final payment = state.payment;
    final payed = factures.montantTotalTTC - payment.paiement;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildTotalRow('Prix par m3', '${factures.tarifM3} Ar'),
          buildTotalRow('Total général (Incl. Taxe)', '${factures.montantTotalTTC} Ar'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: buildTotalRow('Total', '${factures.montantTotalTTC} Ar'),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: buildTotalRow('Reste à payer', '$payed Ar'),
          ),
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
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(amount, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget buildPayButton(BuildContext context, PayementLoaded state, AuthState authState) {
    final bool isFactureAbsent = state.factures.statut == 'Pas trouvé.';
    final bool isMontantNul = state.factures.montantTotalTTC == 0.0;

    final bool isFacturePayee = state.specificDateReleves.any((releve) => releve.etatFacture == 'Payé');

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isFactureAbsent || isMontantNul || isFacturePayee
              ? null
              : () {
            _showFormDialog(context, state, authState);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isFactureAbsent || isMontantNul
                ? Colors.grey
                : isFacturePayee
                ? Colors.orange
                : Colors.blue,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.payment, color: Colors.white),
              const SizedBox(width: 10.0),
              Text(
                isFacturePayee ? 'Modification' : 'Payer',
                style: const TextStyle(fontSize: 18.0, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFormDialog(BuildContext context, PayementLoaded state, AuthState authState) async {
    TextEditingController amountController = TextEditingController();
    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Paiement'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Montant à payer : ${state.factures.montantTotalTTC}'),
                TextFormField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: 'Entrez le montant',
                  ),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un montant';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Veuillez entrer un nombre valide';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState != null && formKey.currentState!.validate()) {
                  double amount = double.parse(amountController.text);
                  if (authState is AuthSuccess) {
                    final paymentBloc = context.read<PaymentBloc>();
                    paymentBloc.add(UpdateFacture(
                      idFacture: state.factures.id,
                      montant: amount,
                    ));
                  }
                  Navigator.of(context).pop(); // Fermer la boîte de dialogue
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Paiement effectué avec succès')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('Payer'),
            ),
          ],
        );
      },
    );
  }
}

