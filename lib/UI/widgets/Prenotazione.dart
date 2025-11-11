import 'package:flutter/material.dart';

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

class PrenotazioniWidget extends StatelessWidget {
  final List<Prenotazione> prenotazioni;

  const PrenotazioniWidget({super.key, required this.prenotazioni});

  @override
  Widget build(BuildContext context) {
    if(prenotazioni.isNotEmpty){
      return ListView.builder(
        itemCount: prenotazioni.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final p = prenotazioni[index];

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 3,
            child: ListTile(
              leading: Icon(
                Icons.sports_tennis,
                color: p.stato == "Confermato" ? Colors.green : Colors.grey,
                size: 32,
              ),
              title: Text(
                p.campo,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text(
                "${p.data} • ${p.ora}",
                style: const TextStyle(fontSize: 14),
              ),
              trailing: Chip(
                label: Text(
                  p.stato,
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: p.stato == "Confermato"
                    ? Colors.green
                    : Colors.redAccent,
              ),
              onTap: () {
                // esempio di azione
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Prenotazione di ${p.campo}')),
                );
              },
            ),
          );
        },
      );
    }
    return const Padding(
      padding: EdgeInsets.fromLTRB(15, 0, 0, 10),
      child: Text(
        "Non hai prenotazioni attive!",
        style: TextStyle(
          fontSize: 20
        ),
      ),
    );
  }
}


