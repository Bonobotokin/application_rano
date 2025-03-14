import 'package:flutter/material.dart';

class MaskedTextField extends StatefulWidget {
  final String mask; // Ajout du paramètre mask
  final TextEditingController controller;
  final InputDecoration inputDecoration;
  final ValueChanged<String>? onChanged;

  const MaskedTextField({
    super.key,
    required this.mask, // Déclarer le paramètre mask
    required this.controller,
    required this.inputDecoration,
    this.onChanged,
  });

  @override
  MaskedTextFieldState createState() => MaskedTextFieldState();
}

class MaskedTextFieldState extends State<MaskedTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: TextInputType.number,
      decoration: widget.inputDecoration,
      onChanged: (text) {
        var len = text.length;
        var cursorPosition = widget.controller.selection.baseOffset;

        if (len == 4 || len == 7) { // Correction des indices pour insérer le séparateur
          widget.controller.text = '$text-';
          widget.controller.selection = TextSelection.collapsed(
            offset: cursorPosition + 1,
          );
        } else if (len > 10) {
          widget.controller.text = text.substring(0, 10);
          widget.controller.selection = const TextSelection.collapsed(
            offset: 10,
          );
        }
        if (len >= 10 && widget.onChanged != null) {
          widget.onChanged!(widget.controller.text);
        }
      },
    );
  }
}
