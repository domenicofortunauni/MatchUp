import 'package:flutter/material.dart';
import '../../../model/objects/PartitaModel.dart';
import '../../../model/support/Constants.dart';
import '../../behaviors/AppLocalizations.dart';
import 'package:intl/intl.dart';

class MatchCard extends StatelessWidget {
  final PartitaModel partita;
  const MatchCard({required this.partita});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final MaterialColor vittoriaSconfitta = partita.isVittoria ? Colors.green : Colors.red;
    final Color cardBg = isDarkMode ? Constants.matchCardColorDark : Constants.matchCardColorLight;

    // Iniziali avversario
    String iniziali = partita.avversario.isNotEmpty ? partita.avversario[0].toUpperCase() : "?";

    if (partita.avversario.contains(" ")) {
      try {
        iniziali = partita.avversario.split(" ").map((e) => e[0]).take(2).join().toUpperCase();
      } catch (e) {
      }
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        // Ombra con il tema chiaro
        boxShadow: [BoxShadow(
            color: isDarkMode? Colors.transparent:Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),],
          border: isDarkMode ? Border.all(color: Colors.white.withValues(alpha: 0.1)) : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 6, color: vittoriaSconfitta), // Striscia verde/rossa laterale
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        child: Text( iniziali,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),
                      // Nome e Data
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              partita.avversario,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                                DateFormat.yMMMMd(Localizations.localeOf(context).toString()).format(partita.data),
                                style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Punteggio
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Badge Vittoria/Sconfitta
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: vittoriaSconfitta.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              partita.isVittoria ?
                              AppLocalizations.of(context)!.translate("Vittoria") :
                              AppLocalizations.of(context)!.translate("Sconfitta"),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: vittoriaSconfitta,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Set
                          Text(
                            "${partita.setVinti} - ${partita.setPersi}",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          // Games
                          Text(
                            "${AppLocalizations.of(context)!.translate("games")}: ${partita.gameVinti}-${partita.gamePersi}",
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}