// File: SfideDisponibili.dart

import 'package:flutter/material.dart';

// Classe pubblica (Mantieni questa definizione)
class SfidaModel {
  final String title;
  final String opponent;

  SfidaModel({required this.title, required this.opponent});
}

// Classe pubblica
class SfideDisponibiliList extends StatelessWidget {
  final List<SfidaModel> sfide;
  // Aggiungiamo la callback function
  final Function(SfidaModel) onAccetta;

  // Aggiorniamo il costruttore
  const SfideDisponibiliList({Key? key, required this.sfide, required this.onAccetta}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (sfide.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("Nessuna sfida disponibile al momento.", style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sfide.length,
      itemBuilder: (context, index) {
        final sfida = sfide[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.flash_on, color: Colors.amber),
            title: Text(sfida.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("vs ${sfida.opponent}"),
            trailing: ElevatedButton(
              onPressed: () {
                // Chiamiamo la funzione passata dal genitore
                onAccetta(sfida);
              },
              child: const Text('Accetta'),
            ),
          ),
        );
      },
    );
  }
}