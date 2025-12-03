import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matchup/model/objects/SfidaModel.dart'; // Percorso del tuo modello
import 'package:matchup/UI/widgets/cards/SfidaCard.dart'; // Percorso della tua card
import '../CustomSnackBar.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';

class SfideInviateSection extends StatelessWidget {
  const SfideInviateSection({Key? key}) : super(key: key);

  Future<void> _eliminaSfida(BuildContext context, String sfidaId) async {
    try {
      await FirebaseFirestore.instance.collection('sfide').doc(sfidaId).delete();
      if (context.mounted) {
        CustomSnackBar.show(context, AppLocalizations.of(context)!.translate("Sfida annullata/eliminata."));
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.show(context, "${AppLocalizations.of(context)!.translate("Errore: ")}$e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sfide')
          .where('challengerId', isEqualTo: currentUserId)
          .where('stato', isEqualTo: 'aperta')
          .snapshots(),
      builder: (context, snapshot) {

        if (snapshot.hasError) return Text(AppLocalizations.of(context)!.translate("Errore caricamento."));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        final List<SfidaModel> sfideValide = [];
        for (var doc in docs) {
          final dataMap = doc.data() as Map<String, dynamic>;

          try {
            Timestamp? ts = dataMap['data'];
            String? oraStr = dataMap['ora'];

            if (ts != null && oraStr != null) {
              DateTime d = ts.toDate();
              List<String> parts = oraStr.split(':');
              DateTime dataScadenza = DateTime(d.year, d.month, d.day, int.parse(parts[0]), int.parse(parts[1]));

              if (dataScadenza.isBefore(DateTime.now())) {
                // SCADUTA: Cancella e salta
                FirebaseFirestore.instance.collection('sfide').doc(doc.id).delete();
                continue;
              }
            }
          } catch (e) {
            // Ignora errori di parsing
          }

          // Se valida, aggiungi
          sfideValide.add(SfidaModel.fromSnapshot(doc));
        }
        // ------------------------------------

        // DIVIDO LE LISTE (sulle sfide valide)
        final sfideDirette = sfideValide.where((s) => s.modalita == 'diretta').toList();
        final sfidePubbliche = sfideValide.where((s) => s.modalita == 'pubblica').toList();

        if (sfideValide.isEmpty) {
          return SizedBox(
            height: 100,
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.translate("Nessuna sfida inviata attiva."),
                style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SEZIONE SFIDE DIRETTE
            if (sfideDirette.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                child: Text(
                  AppLocalizations.of(context)!.translate("Inviti diretti (In attesa)"),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
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

            // SEZIONE SFIDE PUBBLICHE
            if (sfidePubbliche.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                child: Text(
                  AppLocalizations.of(context)!.translate("Sfide pubbliche (In attesa di sfidanti)"),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
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

  Widget _buildCardSfida(BuildContext context, SfidaModel sfida, {required bool isDiretta}) {
    return SfidaCard(
      sfida: sfida,
      customTitle: isDiretta
          ? "${AppLocalizations.of(context)!.translate("Inviata a: ")}${sfida.opponentName ?? '...'}"
          : AppLocalizations.of(context)!.translate("Sfida pubblica"),
      labelButton: isDiretta
          ? AppLocalizations.of(context)!.translate("Annulla invito")
          : AppLocalizations.of(context)!.translate("Elimina sfida"),
      customButtonColor: Colors.red,
      onPressed: () => _eliminaSfida(context, sfida.id),
      customIcon: isDiretta ? Icons.send : Icons.public,
    );
  }
}