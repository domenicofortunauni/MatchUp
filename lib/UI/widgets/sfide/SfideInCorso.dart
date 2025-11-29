import 'package:flutter/material.dart';
import 'package:matchup/UI/widgets/sfide/SfideDisponibili.dart';
import '../CustomSnackBar.dart';

class SfideInCorsoList extends StatelessWidget {
  final List<SfidaModel> sfide;

  const SfideInCorsoList({Key? key, required this.sfide}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Gestione lista vuota
    if (sfide.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "Nessuna sfida in corso.",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    // Lista delle sfide
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sfide.length,
      itemBuilder: (context, index) {
        final sfida = sfide[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 2,
          child: ListTile(
            leading: const Icon(Icons.sports_tennis, color: Colors.green, size: 30),
            title: Text(
              sfida.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("vs ${sfida.opponent}"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Qui potrai gestire il click per entrare nel dettaglio della partita
                CustomSnackBar.show(context,'Apro la partita contro ${sfida.opponent}');
            },
          ),
        );
      },
    );
  }
}