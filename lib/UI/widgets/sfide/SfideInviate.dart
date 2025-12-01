import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matchup/model/objects/SfidaModel.dart';
import 'package:matchup/UI/widgets/cards/SfidaCard.dart'; // Assicurati di importare la tua Card
import '../CustomSnackBar.dart';

class SfideInviateSection extends StatelessWidget {
  const SfideInviateSection({Key? key}) : super(key: key);

  Future<void> _eliminaSfida(BuildContext context, String sfidaId) async {
    try {
      await FirebaseFirestore.instance.collection('sfide').doc(sfidaId).delete();
      if (context.mounted) CustomSnackBar.show(context, "Sfida annullata/eliminata.");
    } catch (e) {
      if (context.mounted) CustomSnackBar.show(context, "Errore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) return const SizedBox.shrink();

    // STREAM: Scarica TUTTE le mie sfide aperte
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sfide')
          .where('challengerId', isEqualTo: currentUserId)
          .where('stato', isEqualTo: 'aperta')
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

            //SEZIONE SFIDE DIRETTE
            if (sfideDirette.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                child: Text(
                  "Inviti diretti (In attesa)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sfideDirette.length,
                itemBuilder: (context, index) {
                  return _buildCardSfida(context, sfideDirette[index], isDiretta: true);
                },
              ),
              const SizedBox(height: 10),
            ],

            //SEZIONE  SFIDE PUBBLICHE
            if (sfidePubbliche.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                child: Text(
                  "Sfide pubbliche (In attesa di sfidanti)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sfidePubbliche.length,
                itemBuilder: (context, index) {
                  return _buildCardSfida(context, sfidePubbliche[index], isDiretta: false);
                },
              ),
            ],
          ],
        );
      },
    );
  }

  //  riciclo della SfidaCard
  Widget _buildCardSfida(BuildContext context, SfidaModel sfida, {required bool isDiretta}) {
    return SfidaCard(
      sfida: sfida,

      customTitle: isDiretta
          ? "Inviata a: ${sfida.opponentName ?? '...'}"
          : "Sfida pubblica",

      labelButton: isDiretta ? "Annulla invito" : "Elimina sfida",
      customButtonColor: Colors.red,

      onPressed: () => _eliminaSfida(context, sfida.id), customIcon: isDiretta ? Icons.send : Icons.public,
    );
  }
}