import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../behaviors/AppLocalizations.dart';
import '../../pages/Login.dart'; // Controlla il percorso per la pagina Login

class LogoutDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.translate("Logout")),
          content: Text(AppLocalizations.of(context)!.translate("Sei sicuro di voler uscire?")),
          actions: [
            // Tasto Annulla
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Chiude il popup
              },
              child: Text(AppLocalizations.of(context)!.translate("Annulla")),
            ),
            // Tasto Conferma Logout
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();

                // Chiude il dialog
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();

                // Va al Login rimuovendo lo storico
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const Login()),
                        (route) => false,
                  );
                }
              },
              child: Text(
                AppLocalizations.of(context)!.translate("Esci"),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}