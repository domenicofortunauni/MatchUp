import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matchup/model/objects/SfidaModel.dart';
import '../cards/SfidaCard.dart';

class SfideDisponibiliList extends StatelessWidget {
  const SfideDisponibiliList({Key? key}) : super(key: key);

  Future<void> _accettaSfida(BuildContext context, SfidaModel sfida) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      String myName = "Avversario";
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        myName = userDoc.data()?['username'] ?? "Avversario";
      }

      await FirebaseFirestore.instance.collection('sfide').doc(sfida.id).update({
        'opponentId': user.uid,
        'opponentName': myName,
        'stato': 'accettata'
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hai accettato la sfida di ${sfida.challengerName}!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Errore: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sfide')
          .where('stato', isEqualTo: 'aperta')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text("Errore caricamento sfide");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        final sfide = docs
            .map((doc) => SfidaModel.fromSnapshot(doc))
            .where((s) => s.challengerId != currentUserId)
            .toList();

        if (sfide.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.event_busy_rounded, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                const Text("Nessuna sfida disponibile", style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          itemCount: sfide.length,
          itemBuilder: (context, index) {
            final sfida = sfide[index];
            return  SfidaCard(sfida: sfida, onPressed: () => _accettaSfida(context, sfida),customIcon:Icons.bolt_rounded);
          },
        );
      },
    );
  }
}