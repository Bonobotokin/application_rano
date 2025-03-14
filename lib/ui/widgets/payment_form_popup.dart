import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:application_rano/blocs/payements/payement_bloc.dart';
import 'package:application_rano/blocs/payements/payement_event.dart';
import 'package:application_rano/blocs/auth/auth_state.dart';
import 'package:application_rano/data/models/facture_model.dart';

class PaymentFormPopup extends StatefulWidget {
  final FactureModel facture;
  final AuthState authState;

  const PaymentFormPopup({super.key, required this.facture, required this.authState});

  @override
  PaymentFormPopupState createState() => PaymentFormPopupState();
}

class PaymentFormPopupState extends State<PaymentFormPopup> {
  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Paiement'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Montant à payer ${widget.facture.totalConsoHT} Ar :'),
          TextFormField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
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
          child: const Text('Annuler'),
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
          child: const Text('Payer'),
        ),
      ],
    );
  }
}
