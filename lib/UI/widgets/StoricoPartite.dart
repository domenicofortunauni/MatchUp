import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';

import '../../model/objects/PartitaModel.dart';

class StoricoPartiteWidget extends StatefulWidget {
  final List<Partita> partite;

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
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.translate("Storico Partite"),
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
                                  AppLocalizations.of(context)!.translate("Data:") +
                                      " ${DateFormat('dd MMMM yyyy').format(partita.data)}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  AppLocalizations.of(context)!.translate("Game Vinti:") +
                                      " ${partita.gameVinti}" +
                                      AppLocalizations.of(context)!.translate(" • Game Persi:") +
                                      " ${partita.gamePersi}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  AppLocalizations.of(context)!.translate("Set Vinti:") +
                                      " ${partita.setVinti}" +
                                      AppLocalizations.of(context)!.translate(" • Set Persi:") +
                                      " ${partita.setPersi}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  partita.isVittoria ? AppLocalizations.of(context)!.translate("Vittoria") :
                                  AppLocalizations.of(context)!.translate("Sconfitta"),
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
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.translate("Nessuna partita nello storico!"),
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