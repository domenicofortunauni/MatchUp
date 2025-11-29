import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matchup/model/objects/SfidaModel.dart';
import '../CustomSnackBar.dart';

class SfideInCorsoList extends StatelessWidget {
  const SfideInCorsoList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return const SizedBox.shrink();
    }

    // STREAM: Ascolta le sfide in stato 'accettata' dove io sono creatore O avversario
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sfide')
          .where('stato', isEqualTo: 'accettata')
          .where(Filter.or(
          Filter('challengerId', isEqualTo: currentUserId), // Caso 1: L'ho creata io
          Filter('opponentId', isEqualTo: currentUserId)    // Caso 2: L'ho accettata io
      ))
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Errore nel caricamento delle sfide."));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        // Convertiamo i documenti in oggetti SfidaModel
        final sfide = docs.map((doc) => SfidaModel.fromSnapshot(doc)).toList();

        // Gestione lista vuota
        if (sfide.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "Nessuna sfida in corso al momento.",
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

            // LOGICA NOMI:
            // Se io sono il creatore (challenger), l'avversario è l'opponent.
            // Se io sono l'opponent, l'avversario è il challenger.
            bool isMyChallenge = sfida.challengerId == currentUserId;

            String nomeAvversario = isMyChallenge
                ? (sfida.opponentName ?? "Sconosciuto")
                : sfida.challengerName;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

                // Icona Racchette incrociate o campo
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.sports_tennis, color: Colors.green, size: 24),
                ),

                title: Text(
                  sfida.nomeStruttura,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      "vs $nomeAvversario", // Mostra il nome corretto
                      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      sfida.dataOra, // Es: 22/10 - 18:00
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),

                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),

                onTap: () {
                  // Qui in futuro potrai aprire la pagina del match con il punteggio
                  CustomSnackBar.show(context, 'Apro la partita contro $nomeAvversario');
                },
              ),
            );
          },
        );
      },
    );
  }
}