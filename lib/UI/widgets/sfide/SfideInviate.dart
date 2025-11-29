import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matchup/model/objects/SfidaModel.dart';
import '../CustomSnackBar.dart';

class SfideInviateSection extends StatelessWidget {
  const SfideInviateSection({Key? key}) : super(key: key);

  Future<void> _eliminaSfida(BuildContext context, String sfidaId) async {
    try {
      await FirebaseFirestore.instance.collection('sfide').doc(sfidaId).delete();
      CustomSnackBar.show(context, "Sfida annullata/eliminata.");
    } catch (e) {
      CustomSnackBar.show(context, "Errore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) return const SizedBox.shrink();

    // STREAM: Scarica TUTTE le mie sfide aperte (sia dirette che pubbliche)
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sfide')
          .where('challengerId', isEqualTo: currentUserId)
          .where('stato', isEqualTo: 'aperta')
      // Non filtriamo per modalità qui, le prendiamo tutte e le dividiamo dopo
          .snapshots(),
      builder: (context, snapshot) {

        if (snapshot.hasError) return const Text("Errore caricamento.");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        final tutteLeSfide = docs.map((doc) => SfidaModel.fromSnapshot(doc)).toList();

        // DIVIDO LE LISTE
        final sfideDirette = tutteLeSfide.where((s) => s.modalita == 'diretta').toList();
        final sfidePubbliche = tutteLeSfide.where((s) => s.modalita == 'pubblica').toList();

        if (tutteLeSfide.isEmpty) {
          return const SizedBox(
            height: 100,
            child: Center(
              child: Text(
                "Nessuna sfida inviata o creata.",
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // --- SEZIONE 1: SFIDE DIRETTE ---
            if (sfideDirette.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                child: Text(
                  "Inviti Diretti (In attesa)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sfideDirette.length,
                itemBuilder: (context, index) {
                  final sfida = sfideDirette[index];
                  return _buildCardSfida(context, sfida, isDiretta: true);
                },
              ),
              const SizedBox(height: 20),
            ],

            // --- SEZIONE 2: SFIDE PUBBLICHE ---
            if (sfidePubbliche.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                child: Text(
                  "Sfide Pubbliche (In attesa di sfidanti)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sfidePubbliche.length,
                itemBuilder: (context, index) {
                  final sfida = sfidePubbliche[index];
                  return _buildCardSfida(context, sfida, isDiretta: false);
                },
              ),
            ],
          ],
        );
      },
    );
  }

  // Widget helper per non ripetere il codice della Card
  Widget _buildCardSfida(BuildContext context, SfidaModel sfida, {required bool isDiretta}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isDiretta ? Colors.orange.shade100 : Colors.blue.shade100,
          child: Icon(
            isDiretta ? Icons.send : Icons.public, // Icona diversa per distinguere
            color: isDiretta ? Colors.orange : Colors.blue,
          ),
        ),

        title: Text(
            sfida.nomeStruttura,
            style: const TextStyle(fontWeight: FontWeight.bold)
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDiretta)
              Text("Inviata a: ${sfida.opponentName ?? '...'}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87))
            else
              const Text("Visibile a tutti",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),

            Text("${sfida.dataOra} - ${sfida.livello}", style: const TextStyle(fontSize: 12)),
          ],
        ),

        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _eliminaSfida(context, sfida.id),
          tooltip: isDiretta ? "Annulla invito" : "Elimina sfida pubblica",
        ),
      ),
    );
  }
}