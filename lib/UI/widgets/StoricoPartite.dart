import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Partita2 {
  final String avversario;   // Nome dell'avversario
  final int gameVinti;        // Game vinti nella partita
  final int gamePersi;        // Game persi nella partita
  final int setVinti;         // Set vinti
  final int setPersi;         // Set persi
  final bool isVittoria;      // true se la partita è stata vinta
  final DateTime data;        // Data della partita

  Partita2({
    required this.avversario,
    required this.gameVinti,
    required this.gamePersi,
    required this.setVinti,
    required this.setPersi,
    required this.isVittoria,
    required this.data,
  });
}




class StoricoPartiteWidget extends StatelessWidget {
  final List<Partita2> partite;

  const StoricoPartiteWidget({super.key, required this.partite});

  @override
  Widget build(BuildContext context) {
    if (partite.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "Nessuna partita nello storico!",
          style: TextStyle(fontSize: 20),
        ),
      );
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titolo principale
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  "Storico Partite",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Lista partite
            ...partite.map((partita) {
              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    title: Text(
                      "vs ${partita.avversario}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Data: ${DateFormat('dd MMMM yyyy').format(partita.data)}",
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          "Game Vinti: ${partita.gameVinti}  •  Game Persi: ${partita.gamePersi}",
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          "Set Vinti: ${partita.setVinti}  •  Set Persi: ${partita.setPersi}",
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          partita.isVittoria ? "Vittoria" : "Sconfitta",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: partita.isVittoria ? Colors.green : Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(thickness: 1),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
