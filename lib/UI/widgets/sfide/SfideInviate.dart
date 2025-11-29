import 'package:flutter/material.dart';
import 'package:matchup/UI/widgets/sfide/SfideDisponibili.dart';

class SfideInviateSection extends StatelessWidget {
  final List<SfidaModel>? sfideInviate;

  const SfideInviateSection({
    Key? key,
    this.sfideInviate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<SfidaModel> listaSicura = sfideInviate ?? [];

    if (listaSicura.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            "Nessuna sfida inviata ancora.",
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      key: ValueKey(listaSicura.length),
      itemCount: listaSicura.length,
      itemBuilder: (context, index) {
        final sfida = listaSicura[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.shade100,
              child: const Icon(Icons.send, color: Colors.orange),
            ),
            title: Text(
              sfida.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Inviata a: ${sfida.opponent}"),
            trailing: const Icon(Icons.access_time, color: Colors.grey),
          ),
        );
      },
    );
  }
}