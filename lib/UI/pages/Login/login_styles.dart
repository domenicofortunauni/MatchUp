import 'package:flutter/material.dart';

InputDecoration loginInputDecoration({
  required BuildContext context,
  required String label,
  required IconData icon,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final inputFillColor = isDark ? Colors.grey[900] : Colors.grey[100];

  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
    ),
    filled: true,
    fillColor: inputFillColor,
    contentPadding:
    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
  );
}

ButtonStyle loginButtonStyle(BuildContext context) {
  final primary = Theme.of(context).colorScheme.primary;

  return ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22),
    ),
    elevation: 5,
  );
}
