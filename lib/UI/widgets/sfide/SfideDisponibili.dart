import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matchup/model/objects/SfidaModel.dart';
import '../CustomSnackBar.dart';
import '../EmptyWidget.dart';
import '../cards/SfidaCard.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';

class SfideDisponibiliList extends StatelessWidget {
  const SfideDisponibiliList({Key? key}) : super(key: key);

  Future<void> _accettaSfida(BuildContext context, SfidaModel sfida) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      // Ottengo il mio nome utente
      String myName = AppLocalizations.of(context)!.translate("Avversario");
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      // Aggiorno il nome con quello reale se esiste
      if (userDoc.exists) {
        myName = userDoc.data()?['username'];
      }
      await FirebaseFirestore.instance.collection('sfide').doc(sfida.id).update({
        'opponentId': user.uid,
        'opponentName': myName,
        'stato': 'accettata'
      });
      if (context.mounted) {
        CustomSnackBar.show(context, "${AppLocalizations.of(context)!.translate("Hai accettato la sfida di ")}${sfida.challengerName}!");
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.showError(
            context, "${AppLocalizations.of(context)!.translate('Errore: ')}$e"
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sfide')
          .where('stato', isEqualTo: 'aperta')
          .where('modalita', isEqualTo: 'pubblica')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Text(AppLocalizations.of(context)!.translate("Errore caricamento sfide"));
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        final List<SfidaModel> sfideValide = [];

        for (var sfidaAperta in docs) {
          final sfidaMap = sfidaAperta.data() as Map<String, dynamic>;
          //Escludo le mie sfide
          if (sfidaMap['challengerId'] == currentUserId) continue;
          //Controllo scadenza sui dati
          try {
            Timestamp? ts = sfidaMap['data'];
            String? oraStr = sfidaMap['ora'];
            if (ts != null && oraStr != null) {
              DateTime d = ts.toDate();
              List<String> parts = oraStr.split(':');
              DateTime dataScadenza = DateTime(d.year, d.month, d.day, int.parse(parts[0]), int.parse(parts[1]));
              if (dataScadenza.isBefore(DateTime.now())) {
                // se SCADUTA Cancello dal DB e continuo
                FirebaseFirestore.instance.collection('sfide').doc(sfidaAperta.id).delete();
                continue;
              }
            }
          } catch (e) {
            // Se c'è errore nei dati, la teniamo per sicurezza
          }
          //Se è valida, creo il model e la aggiungo alla lista
          sfideValide.add(SfidaModel.fromSnapshot(sfidaAperta));
        }
        if (sfideValide.isEmpty) {
          return Center(
            child: EmptyWidget(
              text: AppLocalizations.of(context)!.translate("Nessuna sfida disponibile"),
              subText: AppLocalizations.of(context)!.translate("Controlla più tardi o crea una nuova sfida!"),
              icon: Icons.event_busy_rounded,
            )
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          itemCount: sfideValide.length,
          itemBuilder: (context, index) {
            final sfida = sfideValide[index];
            return SfidaCard(
              sfida: sfida,
              onPressed: () => _accettaSfida(context, sfida),
              customIcon: Icons.bolt_rounded,
              labelButton: AppLocalizations.of(context)!.translate("Accetta sfida"),
            );
          },
        );
      },
    );
  }
}