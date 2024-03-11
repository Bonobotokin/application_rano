import 'package:flutter/material.dart';

class PaymentFacture extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paiement des factures'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildHeader(),
            buildOrderDetails(),
            buildTotal(),
            buildPayButton(context),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      color: Colors.blue[100],
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: Center(
        child: Text(
          'Facture de Randria - 16729',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget buildOrderDetails() {
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
          buildOrderItem('2024-01-25', '300', '10'),
          buildOrderItem('024-02-25', '320','20'),
        ],
      ),
    );
  }

  Widget buildOrderItem(String item, String sku,  String subtotal) {
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
            SizedBox(width: 10.0), // Espacement entre les deux éléments
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
            SizedBox(width: 10.0), // Espacement entre les deux éléments
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

  Widget buildTotal() {
    return Container(
      color: Colors.blue[100],
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: [
          buildTotalRow('Total', '5000 Ar'),
          buildTotalRow('Prix par m3', '200 Ar'),
          buildTotalRow('Total général (Incl. Taxe)', '5220 Ar'),
          buildTotalRow('Taxe', '20 Ar'),
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
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(amount),
        ],
      ),
    );
  }

  Widget buildPayButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // Action à effectuer lors du clic sur le bouton "Payer"
            // Par exemple, vous pouvez naviguer vers une autre page pour le processus de paiement
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: EdgeInsets.symmetric(vertical: 15.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.payment, color: Colors.white),
              SizedBox(width: 10.0),
              Text(
                'Payer',
                style: TextStyle(fontSize: 18.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
