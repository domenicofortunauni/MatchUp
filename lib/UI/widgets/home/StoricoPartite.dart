import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import '../../../model/objects/PartitaModel.dart';
import '../EmptyWidget.dart';
import '../cards/MatchCard.dart';

class StoricoPartiteWidget extends StatefulWidget {
  const StoricoPartiteWidget({Key? key}) : super(key: key);
  @override
  State<StoricoPartiteWidget> createState() => _StoricoPartiteWidgetState();
}
class _StoricoPartiteWidgetState extends State<StoricoPartiteWidget> {
  String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  @override
  Widget build(BuildContext context) {
    if (currentUserId.isEmpty) {
      return const SizedBox.shrink();
    }
    //data limite (30 giorni fa da adesso)
    final DateTime dataLimite = DateTime.now().subtract(const Duration(days: 30));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
          child: Text(
            AppLocalizations.of(context)!.translate("Storico partite (ultimi 30 giorni)"),
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800,),
          ),
        ),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('partite')
              .where('userId', isEqualTo: currentUserId)
              .where('data', isGreaterThanOrEqualTo: Timestamp.fromDate(dataLimite))
              .orderBy('data', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError)
              return Center(child: Text("${AppLocalizations.of(context)!.translate("Errore:")} ${snapshot.error}"));
            if (snapshot.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return Center(
                child:EmptyWidget(
                  text: AppLocalizations.of(context)!.translate("Nessuna partita nello storico"),
                  subText: AppLocalizations.of(context)!.translate("Le partite giocate appariranno qui"),
                  icon: Icons.sports_tennis_outlined,
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                Timestamp ts = data['data'];
                DateTime dataPartita = ts.toDate();
                final partita = PartitaModel(
                  avversario: data['avversario'] ?? '',
                  gameVinti: (data['gameVinti'] as num?)?.toInt() ?? 0,
                  gamePersi: (data['gamePersi'] as num?)?.toInt() ?? 0,
                  setVinti: (data['setVinti'] as num?)?.toInt() ?? 0,
                  setPersi: (data['setPersi'] as num?)?.toInt() ?? 0,
                  data: dataPartita,
                  punteggio: (data['punteggioStringa'] as String?)?.split(' ') ?? [],
                );
                return MatchCard(partita: partita);
              },
            );
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}