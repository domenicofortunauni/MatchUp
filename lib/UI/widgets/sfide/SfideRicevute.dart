import 'package:flutter/material.dart';
import 'package:matchup/UI/widgets/sfide/SfideDisponibili.dart';

class SfideRicevuteSection extends StatelessWidget {
  final List<SfidaModel> sfide;
  final Function(SfidaModel) onAccetta;
  final Function(SfidaModel) onRifiuta;

  const SfideRicevuteSection({
    Key? key,
    required this.sfide,
    required this.onAccetta,
    required this.onRifiuta,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (sfide.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            "Non hai ricevuto nuove sfide.",
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      key: ValueKey(sfide.length),
      itemCount: sfide.length,
      itemBuilder: (context, index) {
        final sfida = sfide[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple.shade100,
                    child: const Icon(Icons.mark_email_unread, color: Colors.purple),
                  ),
                  title: Text(
                    sfida.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Da: ${sfida.opponent}"),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => onRifiuta(sfida),
                        icon: const Icon(Icons.close, size: 18, color: Colors.red),
                        label: const Text("Rifiuta", style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () => onAccetta(sfida),
                        icon: const Icon(Icons.check, size: 18, color: Colors.white),
                        label: const Text("Accetta", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}