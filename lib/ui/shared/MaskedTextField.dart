import 'package:flutter/material.dart';

class MaskedTextField extends StatefulWidget {
  final String mask;
  final TextEditingController controller;
  final InputDecoration inputDecoration;

  const MaskedTextField({
    required this.mask,
    required this.controller,
    required this.inputDecoration,
  });

  @override
  _MaskedTextFieldState createState() => _MaskedTextFieldState();
}

class _MaskedTextFieldState extends State<MaskedTextField> {
  late List<String> _maskParts;

  @override
  void initState() {
    super.initState();
    _maskParts = widget.mask.split('');
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: TextInputType.number,
      decoration: widget.inputDecoration,
      onChanged: (text) {
        String newText = '';
        int maskIndex = 0;

        for (int i = 0; i < text.length; i++) {
          if (maskIndex >= _maskParts.length) break;

          if (_maskParts[maskIndex] == 'x') {
            newText += text[i];
            maskIndex++;
          } else {
            newText += _maskParts[maskIndex];
            maskIndex++;
          }
        }

        widget.controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      },
    );
  }
}
