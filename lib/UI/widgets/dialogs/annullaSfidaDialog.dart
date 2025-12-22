import 'package:flutter/material.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';


class annullaSfidaDialog {
  static Future<bool> showConfirmDialog(BuildContext context, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate("Annulla")),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppLocalizations.of(context)!.translate("No")) ),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(AppLocalizations.of(context)!.translate("Sì, annulla"),
                  style: const TextStyle(color: Colors.red))
          ),
        ],
      ),
    ) ?? false;
  }
}
