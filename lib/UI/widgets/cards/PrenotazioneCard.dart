import 'package:flutter/material.dart';
import '../../../model/objects/PrenotazioneModel.dart';

class PrenotazioneCard extends StatelessWidget {
  final Prenotazione prenotazione;
  final Function(Prenotazione) onAnnulla; // Callback per passare l'azione al padre

  const PrenotazioneCard({
    Key? key,
    required this.prenotazione,
    required this.onAnnulla,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color onSurface = Theme.of(context).colorScheme.onSurface;
    final bool isAnnullato = prenotazione.stato == "Annullato";

    //Check se è passato
    bool isPassata = false;
    try {
      List<String> parts = prenotazione.ora.split(':');
      DateTime startDateTime = DateTime(
          prenotazione.data.year,
          prenotazione.data.month,
          prenotazione.data.day,
          int.parse(parts[0]),
          int.parse(parts[1]));
      DateTime endDateTime = startDateTime.add(Duration(minutes: prenotazione.durata));
      isPassata = endDateTime.isBefore(DateTime.now());
    } catch (_) {}

    //logica colori!
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
              // Striscia laterale
              Container(width: 6, color: statusColor),

              //Contenuto
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ORARIO
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
                                "${prenotazione.durata} min",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Container(height: 40, width: 1, color: Colors.grey.shade300),
                          const SizedBox(width: 16),

                          // Informazioni prenotazione
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
                                      child: Text(
                                        prenotazione.campo,
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.w500),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
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

                      // Bottoni
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isAnnullato)
                            _StatusChip(label: "Annullata", bg: Colors.red.shade50, text: Colors.red)
                          else if (isPassata)
                            _StatusChip(label: "Terminata", bg: Colors.grey.shade200, text: Colors.grey)
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
                                child: const Row(
                                  children: [
                                    Icon(Icons.close, size: 14, color: Colors.red),
                                    SizedBox(width: 4),
                                    Text("Annulla", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
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

// widget privato per le etichette
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