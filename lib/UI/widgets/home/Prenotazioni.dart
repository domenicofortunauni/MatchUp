import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import 'package:matchup/UI/widgets/HorizontalWeekCalendar.dart';
import 'package:matchup/UI/widgets/CustomSnackBar.dart';
import '../../../model/objects/PrenotazioneModel.dart';
import '../cards/PrenotazioneCard.dart';
import 'noPrenotazioniPresenti.dart';

class PrenotazioniWidget extends StatefulWidget {
  const PrenotazioniWidget({Key? key}) : super(key: key);

  @override
  State<PrenotazioniWidget> createState() => _PrenotazioniWidgetState();
}

class _PrenotazioniWidgetState extends State<PrenotazioniWidget> with AutomaticKeepAliveClientMixin{
  DateTime _selectedDate = DateTime.now();
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  late Stream<QuerySnapshot> _prenotazioniStream;

  @override
  void initState() {
    super.initState();
    if (currentUserId.isNotEmpty) {
      DateTime now = DateTime.now();
      DateTime start = now.subtract(const Duration(days: 15));
      DateTime end = now.add(const Duration(days: 15));
      _prenotazioniStream = FirebaseFirestore.instance
          .collection('prenotazioni')
          .where('userId', isEqualTo: currentUserId)
          .where('data', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('data', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .orderBy('data', descending: false)
          .snapshots();
    }
  }

  String _getDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _annullaPrenotazione(Prenotazione p) async {
    if (p.data.isBefore(DateTime.now().subtract(const Duration(hours: 1)))) {
      CustomSnackBar.show(context, "Non puoi annullare prenotazioni passate!");
      return;
    }

    bool conferma = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Annulla Prenotazione"),
        content: Text("Vuoi davvero annullare la prenotazione presso ${p.nomeStruttura}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Sì, annulla", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (!conferma) return;

    try {
      await FirebaseFirestore.instance
          .collection('prenotazioni')
          .doc(p.id)
          .update({'stato': 'Annullato'});

      if (mounted) {
        CustomSnackBar.show(context, "Prenotazione annullata con successo.");
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(context, "Errore: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    if (currentUserId.isEmpty) {
      return const Center(child: Text("Effettua il login per vedere le prenotazioni"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _prenotazioniStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text("Errore: ${snapshot.error}"));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
        }

        final docs = snapshot.data!.docs;
        Map<String, List<Prenotazione>> mappaPrenotazioni = {};

        for (var doc in docs) {
          Prenotazione p = Prenotazione.fromSnapshot(doc);
          String key = _getDateKey(p.data);

          if (!mappaPrenotazioni.containsKey(key)) {
            mappaPrenotazioni[key] = [];
          }
          mappaPrenotazioni[key]!.add(p);
        }

        int countPrenotazioniFast(DateTime date) {
          String key = _getDateKey(date);
          if (mappaPrenotazioni.containsKey(key)) {
            return mappaPrenotazioni[key]!.where((p) => p.stato != "Annullato").length;
          }
          return 0;
        }

        String selectedKey = _getDateKey(_selectedDate);
        List<Prenotazione> prenotazioniDelGiorno = mappaPrenotazioni[selectedKey] ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15,5,15,10),
              child:
                    Text(
                      AppLocalizations.of(context)!.translate("Le tue prenotazioni"),
                      style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child:
              HorizontalWeekCalendar(
                selectedDate: _selectedDate,
                showMonthHeader: true,
                allowPastDates: true,
                onDateChanged: (newDate) {
                  setState(() {
                    _selectedDate = newDate;
                  });
                },
                eventCountProvider: countPrenotazioniFast,
              ),
            ),
            // LISTA CARDS
            if (prenotazioniDelGiorno.isEmpty)
              noPrenotazioni()
            else
              ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: prenotazioniDelGiorno.length,
                itemBuilder: (context, index) {
                  return PrenotazioneCard(
                    prenotazione: prenotazioniDelGiorno[index],
                    onAnnulla: _annullaPrenotazione,);
                },
              ),
          ],
        );
      },
    );
  }
//risolve il problema della lentezza della home!
  @override
  bool get wantKeepAlive => true;
}