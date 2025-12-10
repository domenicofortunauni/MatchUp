import 'package:flutter/material.dart';
import 'package:matchup/UI/widgets/home/AggiungiPartitaStatistiche.dart';
import '../../../model/objects/PrenotazioneModel.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';

class PrenotazioneCard extends StatelessWidget {
  final PrenotazioneModel prenotazione;
  final Function(PrenotazioneModel) onAnnulla;
  final Function(PrenotazioneModel)? onPartitaConclusa;

  const PrenotazioneCard({
    Key? key,
    required this.prenotazione,
    required this.onAnnulla,
    this.onPartitaConclusa,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color onSurface = Theme.of(context).colorScheme.onSurface;
    final bool isAnnullato = prenotazione.stato == "Annullato";

    // Check se la prenotazione è passata
    bool isPassata = false;
    try {
      List<String> parts = prenotazione.ora.split(':');
      DateTime startDateTime = DateTime(
          prenotazione.data.year,
          prenotazione.data.month,
          prenotazione.data.day,
          int.parse(parts[0]),
          int.parse(parts[1]));
      // Consideriamo passata la prenotazione dopo la sua durata
      DateTime endDateTime = startDateTime.add(Duration(minutes: prenotazione.durata));
      isPassata = endDateTime.isBefore(DateTime.now());
    } catch (e) {}

    // Logica colori
    Color statusColor = Colors.green;
    Color bgColor = Colors.green.withValues(alpha: 0.15);

    if (isAnnullato) {
      statusColor = Colors.red;
      bgColor = Colors.red.withValues(alpha: 0.15);
    } else if (isPassata) {
      statusColor = Colors.grey;
      bgColor = Colors.grey.withValues(alpha: 0.15);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Striscia laterale colorata
              Container(width: 6, color: statusColor),
              // Contenuto
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // COLONNA ORARIO
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                prenotazione.ora,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: onSurface,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${prenotazione.durata} ${AppLocalizations.of(context)!.translate("min")}",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          // Divisore verticale
                          Container(height: 40, width: 1, color: Colors.grey.shade300),
                          const SizedBox(width: 16),

                          // COLONNA INFO CAMPO
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  prenotazione.nomeStruttura,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: onSurface.withValues(alpha: isAnnullato ? 0.5 : 1),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.sports_tennis, size: 14, color: statusColor),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Builder(
                                          builder: (context) {
                                            //tradurre "Sfida vs" ma mantenere il nome
                                            String testoCampo = prenotazione.campo;
                                            if (testoCampo.startsWith("Sfida vs ")) {
                                              String nomeAvversario = testoCampo.substring(9);
                                              // Traduce "Sfida vs" e riattacca il nome
                                              testoCampo = "${AppLocalizations.of(context)!.translate("Sfida vs")} $nomeAvversario";
                                            }

                                            return Text(
                                              testoCampo,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey.shade700,
                                                  fontWeight: FontWeight.w500),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            );
                                          }
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // BOTTONI (Visualizzati in base allo stato)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isAnnullato)
                            _StatusChip(
                                label: AppLocalizations.of(context)!.translate("Annullata"),
                                bg: Colors.red.shade50,
                                text: Colors.red
                            )
                          else if (isPassata)
                            InkWell(
                              onTap: () async {
                                // RICONOSCIMENTO SFIDA
                                bool isSfida = false;
                                String? avversarioFisso;

                                // Se il nome del campo inizia con "Sfida vs ", estraiamo il nome
                                if (prenotazione.campo.startsWith("Sfida vs ")) {
                                  isSfida = true;
                                  // "Sfida vs " sono 9 caratteri, prendiamo tutto quello che viene dopo
                                  avversarioFisso = prenotazione.campo.substring(9);
                                }

                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AggiungiPartitaStatistiche(
                                      prenotazione: prenotazione,
                                      // Passiamo i parametri per bloccare i campi
                                      isSfida: isSfida,
                                      nomeAvversarioFisso: avversarioFisso,
                                    ),
                                  ),
                                );

                                if (result != null && onPartitaConclusa != null) {
                                  onPartitaConclusa!(prenotazione);
                                }
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                  border: Border.all(
                                      color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                                      width: 1
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                        Icons.emoji_events_outlined,
                                        size: 16,
                                        color: Theme.of(context).primaryColor
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      AppLocalizations.of(context)!.translate("Inserisci risultato"),
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            InkWell(
                              onTap: () => onAnnulla(prenotazione),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.close, size: 14, color: Colors.red),
                                    const SizedBox(width: 4),
                                    Text(
                                        AppLocalizations.of(context)!.translate("Annulla"),
                                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      )
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

// Widget per le etichette di stato
class _StatusChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color text;
  const _StatusChip({required this.label, required this.bg, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}