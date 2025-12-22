import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matchup/model/objects/SfidaModel.dart';
import 'package:matchup/UI/widgets/cards/SfidaCard.dart';
import '../CustomSnackBar.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import 'package:matchup/services/notification_service.dart';
import '../EmptyWidget.dart';

class SfideRicevuteList extends StatelessWidget {
  const SfideRicevuteList({Key? key}) : super(key: key);

  Future<void> _onAccetta(BuildContext context, SfidaModel sfida) async {
    final user = FirebaseAuth.instance.currentUser;
    final docRef = FirebaseFirestore.instance.collection('sfide').doc(sfida.id);

    final snap = await docRef.get();
    final data = snap.data();
    if (user == null) return;

    try {
      String myUsername = "Giocatore";
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userDoc.exists)
        myUsername = userDoc.data()?['username'] ?? myUsername;

      await FirebaseFirestore.instance.collection('sfide').doc(sfida.id).update({
        'stato': 'accettata',
        'opponentId': user.uid,
        'opponentName': myUsername,});

      if (data != null && data['data'] != null && data['ora'] != null) {
        final dt = (data['data'] as Timestamp).toDate();
        final parts = (data['ora'] as String).split(':');
        String oraString = data['ora'];
        final dataCompleta = DateTime(dt.year, dt.month, dt.day, int.parse(parts[0]), int.parse(parts[1])).subtract(const Duration(minutes: 30));

        //Programma notifica 30 minuti prima
        await NotificationService().scheduleNotification(
            sfida.id.hashCode.abs(),
            AppLocalizations.of(context)!.translate("Sfida Accettata!"),
            AppLocalizations.of(context)!.translate("La partita contro") +
                " ${sfida.challengerName} " +
                AppLocalizations.of(context)!.translate("è alle") +
                " $oraString",
            dataCompleta
        );
      }
      CustomSnackBar.show(context, AppLocalizations.of(context)!.translate("Sfida accettata!"),);
    } catch (e) {
      CustomSnackBar.show(context, "${AppLocalizations.of(context)!.translate("Errore: ")}$e",);
    }
  }
  Future<void> _onRifiuta(BuildContext context,SfidaModel sfida) async {
    try {
      await FirebaseFirestore.instance.collection('sfide').doc(sfida.id).delete();
      CustomSnackBar.show(context, AppLocalizations.of(context)!.translate("Sfida rifiutata."));
    }catch(e) {
        CustomSnackBar.show(context,"${AppLocalizations.of(context)!.translate("Errore: ")}$e");}
  }
  @override
  Widget build(BuildContext context) {
    String myUid = FirebaseAuth.instance.currentUser?.uid ?? "";
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('sfide')
          .where('modalita', isEqualTo: 'diretta')
          .where('stato', isEqualTo: 'aperta')
          .where('opponentId', isEqualTo: myUid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text(AppLocalizations.of(context)!.translate("Errore caricamento."));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        final List<SfidaModel> sfide = [];

        for (var sfidaRicevuta in docs) {
          final dataMap = sfidaRicevuta.data() as Map<String, dynamic>;
          try {
            Timestamp? ts = dataMap['data'];
            String? oraStr = dataMap['ora'];
            if (ts != null && oraStr != null) {
              DateTime d = ts.toDate();
              List<String> parts = oraStr.split(':');
              // Combina data e ora
              DateTime dataScadenza = DateTime(d.year, d.month, d.day, int.parse(parts[0]), int.parse(parts[1]));
              // Se la data è passata, cancella e salta
              if (dataScadenza.isBefore(DateTime.now())) {
                FirebaseFirestore.instance.collection('sfide').doc(sfidaRicevuta.id).delete();
                continue;
              }
            }
          } catch (e) {
          }
          // Se è valida, la aggiungiamo alla lista da visualizzare
          sfide.add(SfidaModel.fromSnapshot(sfidaRicevuta));
        }

        if (sfide.isEmpty) {
          return Center(
            child: EmptyWidget(
              text: AppLocalizations.of(context)!.translate("Nessuna sfida ricevuta"),
              subText: AppLocalizations.of(context)!.translate("Le sfide che riceverai appariranno qui"),
              icon: Icons.mark_email_read_rounded,
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
            // Riutilizzo la SfidaCard con bottoni personalizzati
            return SfidaCard(
              customIcon: Icons.mark_email_unread,
              sfida: sfida,
              customTitle: "${AppLocalizations.of(context)!.translate("Sfida da: ")}${sfida.challengerName}",
              extraWidget: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _onRifiuta(context,sfida),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(AppLocalizations.of(context)!.translate("Rifiuta"),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _onAccetta(context,sfida),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(AppLocalizations.of(context)!.translate("Accetta"),
                          style: const TextStyle(fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}