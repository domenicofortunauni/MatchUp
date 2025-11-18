import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Partita2 {
  final String avversario;
  final int gameVinti;
  final int gamePersi;
  final int setVinti;
  final int setPersi;
  final bool isVittoria;
  final DateTime data;

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

class StoricoPartiteWidget extends StatefulWidget {
  final List<Partita2> partite;

  const StoricoPartiteWidget({super.key, required this.partite});

  @override
  State<StoricoPartiteWidget> createState() => _StoricoPartiteWidgetState();
}

class _StoricoPartiteWidgetState extends State<StoricoPartiteWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (widget.partite.isNotEmpty)
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 400,
                ),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: ListView.builder(
                    controller: _scrollController,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(right: 8.0),
                    itemCount: widget.partite.length,
                    itemBuilder: (context, index) {
                      final partita = widget.partite[index];
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
                    },
                  ),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Text(
                    "Nessuna partita nello storico!",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}