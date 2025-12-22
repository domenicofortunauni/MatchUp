import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matchup/model/objects/SfidaModel.dart';
import '../EmptyWidget.dart';
import '../cards/SfidaCard.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';

class SfideInCorsoList extends StatelessWidget {
  const SfideInCorsoList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
     String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null)
      return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sfide')
          .where('stato', isEqualTo: 'accettata')
          .where(Filter.or(
          Filter('challengerId', isEqualTo: currentUserId),
          Filter('opponentId', isEqualTo: currentUserId)
      )).snapshots(),

      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: EmptyWidget(
                text: AppLocalizations.of(context)!.translate("Errore nel caricamento delle sfide."),
                icon: Icons.error_outline,
              )
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        final List<SfidaModel> sfideAttive = [];

        for (var sfida in docs) {
          final dataMap = sfida.data() as Map<String, dynamic>;
          bool isVisible = true; // Siamo "ottimisti" la mostriamo, se è scaduta non la mostriamo
          try {
            // Recupero data e ora dal documento
            Timestamp? ts = dataMap['data']; // campo data come Timestamp
            String? oraStr = dataMap['ora']; // campo ora come stringa "HH:mm"
            if (ts != null && oraStr != null) {
              DateTime d = ts.toDate();
              List<String> parts = oraStr.split(':');
              int h = int.parse(parts[0]);
              int m = int.parse(parts[1]);
              // Calcolo data inizio partita
              DateTime dataInizio = DateTime(d.year, d.month, d.day, h, m);
              // Calcolo fine stimata (inizio + 2 ore) (le prenotazioni durano massimo 2 ore)
              DateTime dataFine = dataInizio.add(const Duration(hours: 2));
              // Se ADESSO è dopo la fine stimata, nascondi la sfida
              if (DateTime.now().isAfter(dataFine)) {
                //andrebbero cancellate pure, ma magari andrebbe fatto fare ad un utente gestore dell'app?
                isVisible = false;
              }
            }
          } catch (e) {
            // In caso di errore, nascondo la sfida
            isVisible = false;
          }
          if (isVisible) {
            // Aggiungo alla lista delle sfide attive se non è diventata invisibile
            sfideAttive.add(SfidaModel.fromSnapshot(sfida));
          }
        }
        if (sfideAttive.isEmpty) {
          return Center(
            child: EmptyWidget(
              text: AppLocalizations.of(context)!.translate("Nessuna sfida in corso al momento."),
              subText: AppLocalizations.of(context)!.translate("Le sfide accettate appariranno qui."),
              icon: Icons.sports_tennis_outlined,
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sfideAttive.length,
          itemBuilder: (context, index) {
            final sfida = sfideAttive[index];
            // Determino il nome da mostrare in base a chi è l'utente corrente
            bool isMyChallenge = sfida.challengerId == currentUserId;
            // Se sono il challenger della sfida, mostro l'opponent e viceversa
            String nomeDaMostrare = isMyChallenge ? (sfida.opponentName ?? AppLocalizations.of(context)!.translate("Avversario")) : sfida.challengerName;
            return SfidaCard(
              sfida: sfida,
              customTitle: "vs $nomeDaMostrare",
              customIcon: Icons.sports_tennis,
            );
          },
        );
      },
    );
  }
}