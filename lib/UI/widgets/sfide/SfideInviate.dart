import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matchup/model/objects/SfidaModel.dart'; // Percorso del tuo modello
import 'package:matchup/UI/widgets/cards/SfidaCard.dart'; // Percorso della tua card
import '../CustomSnackBar.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import '../EmptyWidget.dart';

class SfideInviateList extends StatelessWidget {
  const SfideInviateList({Key? key}) : super(key: key);

  // metodo per eliminare la sfida
  Future<void> _eliminaSfida(BuildContext context, String sfidaId) async {
    try {
      await FirebaseFirestore.instance.collection('sfide').doc(sfidaId).delete();
      if (context.mounted)
        CustomSnackBar.show(context, AppLocalizations.of(context)!.translate("Sfida annullata."));
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.show(context, "${AppLocalizations.of(context)!.translate("Errore: ")}$e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sfide')
          .where('challengerId', isEqualTo: currentUserId)
          .where('stato', isEqualTo: 'aperta')
          .snapshots(),
      builder: (context, snapshot) {

        if (snapshot.hasError) return Text(AppLocalizations.of(context)!.translate("Errore caricamento."));
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        final List<SfidaModel> sfideDirette = [];
        final List<SfidaModel> sfidePubbliche = [];
        for (var sfidaApertaDaMe in docs) {
          final dataMap = sfidaApertaDaMe.data() as Map<String, dynamic>;

          try {
            Timestamp? ts = dataMap['data'];
            String? oraStr = dataMap['ora'];
            if (ts != null && oraStr != null) {
              DateTime d = ts.toDate();
              List<String> parts = oraStr.split(':');
              DateTime dataScadenza = DateTime(d.year, d.month, d.day, int.parse(parts[0]), int.parse(parts[1]));

              if (dataScadenza.isBefore(DateTime.now())) {
                // Sfida scaduta, elimina
                FirebaseFirestore.instance.collection('sfide').doc(sfidaApertaDaMe.id).delete();
                continue;
              }
            }
          } catch (e) {}
          // Se valida costruisco l'oggetto sfida
          final sfida = SfidaModel.fromSnapshot(sfidaApertaDaMe);
          // Aggiungo alla lista delle sfide valide separandole per modalità
          if (sfida.modalita == 'diretta') {
            sfideDirette.add(sfida);
          } else if (sfida.modalita == 'pubblica') {
            sfidePubbliche.add(sfida);
          }
        }
        if (sfideDirette.isEmpty && sfidePubbliche.isEmpty) {
          return Center(
            child: EmptyWidget(
                text: AppLocalizations.of(context)!.translate("Nessuna sfida inviata attiva."),
                subText: AppLocalizations.of(context)!.translate("Le sfide che invii appariranno qui"),
                icon: Icons.sports_tennis_outlined,
              ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sezione sfide dirette
            if (sfideDirette.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(8,0,8,10),
                child: Text(
                  AppLocalizations.of(context)!.translate("Inviti diretti (In attesa)"),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.only(bottom: 50),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sfideDirette.length,
                itemBuilder: (context, index) {
                  return _buildCardSfida(context, sfideDirette[index], isDiretta: true);
                },
              ),
            ],
            // Sezione sfide pubbliche
            if (sfidePubbliche.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(8,0,8,10),
                child: Text(
                  AppLocalizations.of(context)!.translate("Sfide pubbliche (In attesa di sfidanti)"),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
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