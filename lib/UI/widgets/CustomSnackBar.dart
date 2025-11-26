import 'package:flutter/material.dart';

class CustomSnackBar {
  static void show(
      BuildContext context,
      String message, {
        Color? backgroundColor,
        Color? textColor,
        Color? iconColor,
      }) {
    // Chiude eventuali SnackBar precedenti
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Determina i colori finali (se nulli usa quelli del tema)
    final bgColor = backgroundColor ?? Theme.of(context).colorScheme.surface;
    final txtColor = textColor ?? Theme.of(context).colorScheme.onSurface;
    final icnColor = iconColor ?? Theme.of(context).colorScheme.onSurface;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: icnColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: txtColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        elevation: 6.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Metodo specifico per gli errori
  static void showError(
      BuildContext context,
      String message, {
        Color? backgroundColor,
      }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      ),
    );
  }
}