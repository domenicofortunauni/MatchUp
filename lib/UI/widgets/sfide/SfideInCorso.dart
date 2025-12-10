import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matchup/model/objects/SfidaModel.dart';
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
        final List<SfidaModel> sfideAttive = [];

        for (var doc in docs) {
          final dataMap = doc.data() as Map<String, dynamic>;

          bool isVisible = true; // Di base la mostriamo, a meno che non sia scaduta

          try {
            // Recupero i dati dal documento Firebase
            Timestamp? ts = dataMap['data'];
            String? oraStr = dataMap['ora'];

            if (ts != null && oraStr != null) {
              DateTime d = ts.toDate();
              List<String> parts = oraStr.split(':');
              int h = int.parse(parts[0]);
              int m = int.parse(parts[1]);

              // Calcolo inizio partita
              DateTime dataInizio = DateTime(d.year, d.month, d.day, h, m);

              // Calcolo fine stimata (inizio + 2 ore)
              // La sfida sparisce dalla lista "In Corso" 2 ore dopo l'inizio
              DateTime dataFine = dataInizio.add(const Duration(hours: 2));

              // Se ADESSO è dopo la fine stimata, nascondi la sfida
              if (DateTime.now().isAfter(dataFine)) {
                isVisible = false;
              }
            }
          } catch (e) {
            // Se i dati sono corrotti, nel dubbio la mostriamo per non perdere info
            isVisible = true;
          }

          if (isVisible) {
            // Creo il modello se la sfida è ancora visibile
            sfideAttive.add(SfidaModel.fromSnapshot(doc));
          }
        }

        if (sfideAttive.isEmpty) {
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
          itemCount: sfideAttive.length,
          itemBuilder: (context, index) {
            final sfida = sfideAttive[index];
            bool isMyChallenge = sfida.challengerId == currentUserId;
            String nomeDaMostrare = isMyChallenge
                ? (sfida.opponentName ?? AppLocalizations.of(context)!.translate("Avversario"))
                : sfida.challengerName;

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