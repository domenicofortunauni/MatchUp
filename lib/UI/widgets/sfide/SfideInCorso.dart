import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matchup/model/objects/SfidaModel.dart';
import '../CustomSnackBar.dart';
import '../cards/SfidaCard.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';


class SfideInCorsoList extends StatelessWidget {
  const SfideInCorsoList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return const SizedBox.shrink();
    }
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sfide')
          .where('stato', isEqualTo: 'accettata')
          .where(Filter.or(
          Filter('challengerId', isEqualTo: currentUserId),
          Filter('opponentId', isEqualTo: currentUserId)
      ))
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text(AppLocalizations.of(context)!.translate("Errore nel caricamento delle sfide."))
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        final sfide = docs.map((doc) => SfidaModel.fromSnapshot(doc)).toList();
        if (sfide.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                AppLocalizations.of(context)!.translate("Nessuna sfida in corso al momento."),
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sfide.length,
          itemBuilder: (context, index) {
            final sfida = sfide[index];
            bool isMyChallenge = sfida.challengerId == currentUserId;
            String nomeDaMostrare = isMyChallenge
                ? (sfida.opponentName ?? AppLocalizations.of(context)!.translate("Avversario"))
                : sfida.challengerName;

            return SfidaCard(
              sfida: sfida,
              customTitle: "vs $nomeDaMostrare",
              customIcon: Icons.sports_tennis,
              labelButton: AppLocalizations.of(context)!.translate("Apri Partita"),
              customButtonColor: Theme.of(context).colorScheme.primary,
              onPressed: () {
                CustomSnackBar.show(
                    context,
                    '${AppLocalizations.of(context)!.translate("Apro partita")} vs $nomeDaMostrare'
                );
              },
            );
          },
        );
      },
    );
  }
}