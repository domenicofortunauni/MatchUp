import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matchup/model/objects/SfidaModel.dart';
import 'package:matchup/UI/widgets/cards/SfidaCard.dart';
import '../CustomSnackBar.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import 'package:matchup/services/notification_service.dart';

class SfideRicevuteSection extends StatefulWidget {
  const SfideRicevuteSection({Key? key}) : super(key: key);

  @override
  State<SfideRicevuteSection> createState() => _SfideRicevuteSectionState();
}

class _SfideRicevuteSectionState extends State<SfideRicevuteSection> {
  String? _myUsername;
  bool _isLoadingUsername = true;

  @override
  void initState() {
    super.initState();
    _fetchMyUsername();
  }

  Future<void> _fetchMyUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            _myUsername = data['username'] ?? data['nome'];
            _isLoadingUsername = false;
          });
        }
      } catch (e) {
        setState(() => _isLoadingUsername = false);
      }
    }
  }

  Future<void> _onAccetta(SfidaModel sfida) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('sfide')
          .doc(sfida.id)
          .get();

      if (!doc.exists) return;

      final dataMap = doc.data() as Map<String, dynamic>;

      await FirebaseFirestore.instance.collection('sfide').doc(sfida.id).update({
        'stato': 'accettata',
        'opponentId': user.uid,
      });

      try {
        if (dataMap.containsKey('data') && dataMap.containsKey('ora')) {
          DateTime giornoPartita = (dataMap['data'] as Timestamp).toDate();
          String oraString = dataMap['ora'];

          final parts = oraString.split(':');
          final dataCompleta = DateTime(
            giornoPartita.year,
            giornoPartita.month,
            giornoPartita.day,
            int.parse(parts[0]),
            int.parse(parts[1]),
          );

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
      } catch (e) {
        print("Impossibile impostare la notifica: $e");
      }

      if (mounted) {
        CustomSnackBar.show(context, AppLocalizations.of(context)!.translate("Sfida accettata!"));
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(context, "${AppLocalizations.of(context)!.translate("Errore: ")}$e");
      }
    }
  }

  Future<void> _onRifiuta(SfidaModel sfida) async {
    try {
      await FirebaseFirestore.instance.collection('sfide').doc(sfida.id).delete();
      if (mounted) {
        CustomSnackBar.show(context, AppLocalizations.of(context)!.translate("Sfida rifiutata."));
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(context, "${AppLocalizations.of(context)!.translate("Errore: ")}$e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUsername) return const Center(child: CircularProgressIndicator());
    if (_myUsername == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sfide')
          .where('modalita', isEqualTo: 'diretta')
          .where('stato', isEqualTo: 'aperta')
          .where('opponentName', isEqualTo: _myUsername)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text(AppLocalizations.of(context)!.translate("Errore caricamento."));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        final List<SfidaModel> sfide = [];

        for (var doc in docs) {
          final dataMap = doc.data() as Map<String, dynamic>;

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
                FirebaseFirestore.instance.collection('sfide').doc(doc.id).delete();
                continue;
              }
            }
          } catch (e) {
          }

          // Se è valida, la aggiungiamo alla lista da visualizzare
          sfide.add(SfidaModel.fromSnapshot(doc));
        }
        // ------------------------------------

        if (sfide.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mark_email_read_rounded, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text(
                    AppLocalizations.of(context)!.translate("Nessuna sfida ricevuta"),
                    style: const TextStyle(color: Colors.grey)
                ),
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

            // RICICLO DELLA SFIDA CARD
            return SfidaCard(
              sfida: sfida,
              customTitle: "${AppLocalizations.of(context)!.translate("Sfida da: ")}${sfida.challengerName}",

              extraWidget: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _onRifiuta(sfida),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(AppLocalizations.of(context)!.translate("Rifiuta")),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _onAccetta(sfida),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                          AppLocalizations.of(context)!.translate("Accetta"),
                          style: const TextStyle(fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),
                ],
              ),
              customIcon: Icons.mark_email_unread,
            );
          },
        );
      },
    );
  }
}