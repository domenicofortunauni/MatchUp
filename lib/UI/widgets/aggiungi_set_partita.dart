import 'package:flutter/material.dart';

class aggiungi_set_partita extends StatelessWidget {
  final TextEditingController me;
  final TextEditingController opponent;
  final String? Function(String?)? validator;

  const aggiungi_set_partita({
    Key? key,
    required this.me,
    required this.opponent,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final numbers = List.generate(8, (i) => i.toString());

    InputDecoration deco = InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      isDense: true,
    );

    Widget buildDropdown(TextEditingController controller) {
      return DropdownButtonFormField<String>(
        initialValue: controller.text.isEmpty ? null : controller.text,
        items: numbers
            .map((n) => DropdownMenuItem(
          value: n,
          child: Text(n),
        ))
            .toList(),
        onChanged: (value) {
          controller.text = value ?? "";
        },
        decoration: deco,
        validator: validator,
      );
    }

    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: IntrinsicWidth(
              child: buildDropdown(me),
            ),
          ),
        ),


        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: IntrinsicWidth(
              child: buildDropdown(opponent),
            ),
          ),
        ),
      ],
    );
  }
}
