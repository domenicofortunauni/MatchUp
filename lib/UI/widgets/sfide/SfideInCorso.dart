import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matchup/model/objects/SfidaModel.dart';
import '../CustomSnackBar.dart';
import '../cards/SfidaCard.dart';

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
            bool isMyChallenge = sfida.challengerId == currentUserId;
            String nomeDaMostrare = isMyChallenge
                ? (sfida.opponentName ?? "Avversario")
                : sfida.challengerName;

            return SfidaCard(
              sfida: sfida,
              customTitle: "vs $nomeDaMostrare",
              customIcon: Icons.sports_tennis,
              labelButton: "Apri Partita",
              customButtonColor: Theme.of(context).colorScheme.primary,
              onPressed: () {
                CustomSnackBar.show(context, 'Apro partita vs $nomeDaMostrare');
              },
            );
          },
        );
      },
    );
  }
}