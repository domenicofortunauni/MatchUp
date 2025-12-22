import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matchup/UI/widgets/home/AggiungiPartitaStatistiche.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import '../../../model/objects/PartitaModel.dart';
import '../../../model/objects/StatisticheModel.dart';
import '../cards/StatisticheCard.dart';

class Statistiche extends StatelessWidget {
  const Statistiche({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('statistiche')
          .where('userId', isEqualTo: currentUserId)
          .orderBy('data', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Center(child: Text("${AppLocalizations.of(context)!.translate("Errore:")} ${snapshot.error}"));
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data?.docs ?? [];
        final partite = docs.map((partita) => PartitaModel.fromFirestore(partita.data() as Map<String, dynamic>)).toList();
        final stats = StatisticheModel.fromPartite(partite);

        return Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TITOLO
              Text(
                AppLocalizations.of(context)!.translate("Le tue statistiche"),
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),
              //card statistiche
              StatisticheCard(stats: stats),
              const SizedBox(height: 16),

              // Bottone aggiungi stats
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AggiungiPartitaStatistiche()),
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    AppLocalizations.of(context)!.translate("Aggiungi nuova partita"),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: colorScheme.primary.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}