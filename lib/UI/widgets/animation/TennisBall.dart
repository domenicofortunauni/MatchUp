import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui'; // Necessario per l'effetto sfocato (Blur)

class Tennisball {
  static Future<void> show(BuildContext context, String message) async {
    final primaryColor = Theme.of(context).colorScheme.primary;

    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Successo",
      barrierColor: Colors.black.withValues(alpha: 0.3), // Sfondo scuro leggero
      transitionDuration: const Duration(milliseconds: 400), // Durata entrata

      // COSTRUZIONE DELLA PAGINA
      pageBuilder: (ctx, anim1, anim2) {
        return Stack(
          children: [
            //SFOCATURA SFONDO (Blur Effect)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.transparent),
            ),

            //IL DIALOGO
            Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 300, // Larghezza fissa per estetica
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25), // Bordi molto arrotondati
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ANIMAZIONE LOTTIE
                      Lottie.asset(
                        'assets/animations/tennisball.json',
                        width: 160,
                        height: 160,
                        repeat: false,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),

                      // TESTO STILIZZATO
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800, // Molto grassetto
                          color: primaryColor, // Colore del tema
                          letterSpacing: 0.5,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },

      // ANIMAZIONE DI ENTRATA (Effetto Rimbalzo/Elastic)
      transitionBuilder: (ctx, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: anim1,
            curve: Curves.elasticOut, // L'effetto "boing" rimbalzante
            reverseCurve: Curves.easeIn,
          ),
          child: child,
        );
      },
    ).timeout(const Duration(seconds: 2), onTimeout: () {
      // Chiude automaticamente
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }return null;
    });
  }
}