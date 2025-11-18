import 'package:flutter/material.dart';
import 'package:matchup/UI/widgets/CustomSnackBar.dart';

class Prenotazione {
  final String campo;
  final String data;
  final String ora;
  final String stato;

  Prenotazione({
    required this.campo,
    required this.data,
    required this.ora,
    required this.stato,
  });
}

class PrenotazioniWidget extends StatefulWidget {
  final List<Prenotazione> prenotazioni;

  const PrenotazioniWidget({super.key, required this.prenotazioni});

  @override
  State<PrenotazioniWidget> createState() => _PrenotazioniWidgetState();
}

class _PrenotazioniWidgetState extends State<PrenotazioniWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(12.0),
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
                  "Le Tue Prenotazioni",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (widget.prenotazioni.isNotEmpty)
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 350,
                ),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: ListView.builder(
                    controller: _scrollController,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: widget.prenotazioni.length,
                    padding: const EdgeInsets.only(right: 8.0),
                    itemBuilder: (context, index) {
                      final p = widget.prenotazioni[index];

                      return Card(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[850]
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (p.stato == "Confermato" ? Colors.green : Colors.grey).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.sports_tennis,
                              color: p.stato == "Confermato" ? Colors.green : Colors.grey,
                              size: 28,
                            ),
                          ),
                          title: Text(
                            p.campo,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              "${p.data} • ${p.ora}",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          trailing: Chip(
                            label: Text(
                              p.stato,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            backgroundColor: p.stato == "Confermato" ? Colors.green : Colors.redAccent,
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onTap: () {
                            CustomSnackBar.show(context, 'Prenotazione di ${p.campo}');
                          },
                        ),
                      );
                    },
                  ),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    "Non hai prenotazioni attive!",
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