import 'package:flutter/material.dart';
import '../../behaviors/AppLocalizations.dart';

class Sfida_button extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  const Sfida_button({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: selected
            ? Theme.of(context).colorScheme.primary
            : Colors.grey.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        AppLocalizations.of(context)!.translate(label),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
