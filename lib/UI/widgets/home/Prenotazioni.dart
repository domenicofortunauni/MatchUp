import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:intl/intl.dart';
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

class _PrenotazioniWidgetState extends State<PrenotazioniWidget> with AutomaticKeepAliveClientMixin {
  DateTime _selectedDate = DateTime.now();
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  late Stream<QuerySnapshot> _prenotazioniStream;

  @override
  void initState() {
    super.initState();
    if (currentUserId.isNotEmpty) {
      DateTime now = DateTime.now();
      DateTime start = now.subtract(const Duration(days: 30));
      DateTime end = now.add(const Duration(days: 30));

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
    DateTime dataBase = p.data;
    DateTime dataOraReale;

    try {
      List<String> parts = p.ora.split(':');
      int ora = int.parse(parts[0]);
      int minuti = int.parse(parts[1]);

      dataOraReale = DateTime(
        dataBase.year,
        dataBase.month,
        dataBase.day,
        ora,
        minuti,
      );
    } catch (e) {
      dataOraReale = p.data;
    }

    //Calcoliamo l'ora limite: adesso + 1 ora di preavviso
    DateTime oraLimite = DateTime.now().add(const Duration(hours: 1));

    if (dataOraReale.isBefore(oraLimite)) {
      CustomSnackBar.show(context, "Troppo tardi! Serve almeno 1 ora di preavviso.");
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

  //Nasconde le partite una volta inserito il risultato
  Future<void> _onPartitaConclusa(Prenotazione p) async {
    try {
      await FirebaseFirestore.instance
          .collection('prenotazioni')
          .doc(p.id)
          .update({'stato': 'Conclusa'});

      if (mounted) {
        CustomSnackBar.show(context, "Risultato salvato! Prenotazione archiviata.");
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(context, "Errore durante l'aggiornamento: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

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

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        for (var doc in docs) {
          Prenotazione p = Prenotazione.fromSnapshot(doc);

          if (p.stato == 'Conclusa') continue;

          //Filtro Partite Annullate Passate
          final pDate = DateTime(p.data.year, p.data.month, p.data.day);

          //Se è annullata ed è precedente a oggi viene nascosta
          if (p.stato == 'Annullato' && pDate.isBefore(today)) {
            continue;
          }

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

        //Ordinamento delle prenotazioni
        prenotazioniDelGiorno.sort((a, b) {
          try {
            final partsA = a.ora.split(':');
            final partsB = b.ora.split(':');
            final dtA = DateTime(2020, 1, 1, int.parse(partsA[0]), int.parse(partsA[1]));
            final dtB = DateTime(2020, 1, 1, int.parse(partsB[0]), int.parse(partsB[1]));
            return dtA.compareTo(dtB);
          } catch (_) {
            return a.ora.compareTo(b.ora);
          }
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 5, 15, 10),
              child: Text(
                AppLocalizations.of(context)!.translate("Le tue prenotazioni"),
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: HorizontalWeekCalendar(
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
            if (prenotazioniDelGiorno.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: noPrenotazioni(),
              )
            else
              ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: prenotazioniDelGiorno.length,
                itemBuilder: (context, index) {
                  return PrenotazioneCard(
                    prenotazione: prenotazioniDelGiorno[index],
                    onAnnulla: _annullaPrenotazione,
                    onPartitaConclusa: _onPartitaConclusa,
                  );
                },
              ),
          ],
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}