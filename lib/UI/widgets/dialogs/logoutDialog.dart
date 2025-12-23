import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matchup/UI/pages/Login/login_page.dart';
import '../../behaviors/AppLocalizations.dart';
import '../MenuLaterale.dart';

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
                Navigator.of(dialogContext).pop();// Chiude il popup
              },
              child: Text(AppLocalizations.of(context)!.translate("Annulla")),
            ),
            // Tasto Esci Logout
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                // Chiude il dialog
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                // Va al Login
                if (context.mounted) {
                  MenuLaterale.userStream = null;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
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