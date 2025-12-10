import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import 'package:matchup/UI/widgets/HorizontalWeekCalendar.dart';
import 'package:matchup/UI/widgets/CustomSnackBar.dart';
import '../../../model/objects/PrenotazioneModel.dart';
import '../cards/PrenotazioneCard.dart';
import 'noPrenotazioniPresenti.dart';
import 'dart:async';

class PrenotazioniWidget extends StatefulWidget {
  const PrenotazioniWidget({Key? key}) : super(key: key);

  @override
  State<PrenotazioniWidget> createState() => _PrenotazioniWidgetState();
}

class _PrenotazioniWidgetState extends State<PrenotazioniWidget> with AutomaticKeepAliveClientMixin {
  DateTime _selectedDate = DateTime.now();
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  List<PrenotazioneModel> _listaPrenotazioniStandard = [];
  List<PrenotazioneModel> _listaSfideAccettate = [];
  List<PrenotazioneModel> _listaSfideMieCreate = [];
  List<PrenotazioneModel> _listaUnificata = [];

  StreamSubscription? _subPrenotazioni;
  StreamSubscription? _subSfide;
  StreamSubscription? _subSfideMieCreate;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (currentUserId.isNotEmpty) {
      _inizializzaStreams();
    }
  }

  @override
  void dispose() {
    _subPrenotazioni?.cancel();
    _subSfide?.cancel();
    _subSfideMieCreate?.cancel();
    super.dispose();
  }

  void _inizializzaStreams() {
    DateTime now = DateTime.now();
    DateTime start = now.subtract(const Duration(days: 30));
    DateTime end = now.add(const Duration(days: 60));

    // STREAM PRENOTAZIONI (Quelle create da me)
    _subPrenotazioni = FirebaseFirestore.instance
        .collection('prenotazioni')
        .where('userId', isEqualTo: currentUserId)
        .where('data', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('data', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('data', descending: false)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _listaPrenotazioniStandard = snapshot.docs
            .map((doc) => PrenotazioneModel.fromSnapshot(doc))
            .toList();
        _unisciEOrdina();
      });
    });

    // STREAM SFIDE DOVE SONO L'AVVERSARIO (Quelle create da ALTRI e accettate da ME)
    _subSfide = FirebaseFirestore.instance
        .collection('sfide')
        .where('opponentId', isEqualTo: currentUserId)
        .where('stato', isEqualTo: 'accettata')
        .where('data', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('data', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _listaSfideAccettate = snapshot.docs.map((doc) {
          final data = doc.data();
          String nomeStruttura = data['nomeStruttura'] ?? "Sfida";
          String challengerName = data['challengerName'] ?? "";

          return PrenotazioneModel(
              id: doc.id,
              nomeStruttura: nomeStruttura,
              campo: "Sfida vs $challengerName",
              data: (data['data'] as Timestamp).toDate(),
              ora: data['ora'] ?? "00:00",
              durata: 90,
              prezzo: 0.0,
              stato: "Confermato"
          );
        }).toList();
        _unisciEOrdina();
      });
    });

    // STREAM SFIDE CHE HO CREATO IO
    _subSfideMieCreate = FirebaseFirestore.instance
        .collection('sfide')
        .where('challengerId', isEqualTo: currentUserId)
        .where('stato', isEqualTo: 'accettata')
        .where('data', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('data', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _listaSfideMieCreate = snapshot.docs.map((doc) {
          final data = doc.data();
          String nomeStruttura = data['nomeStruttura'] ?? "Sfida";
          String opponentName = data['opponentName'] ?? "";

          return PrenotazioneModel(
              id: doc.id,
              nomeStruttura: nomeStruttura,
              campo: "Sfida vs $opponentName",
              data: (data['data'] as Timestamp).toDate(),
              ora: data['ora'] ?? "00:00",
              durata: 90,
              prezzo: 0.0,
              stato: "Confermato"
          );
        }).toList();
        _unisciEOrdina();
      });
    });
  }

  // Unisce le tre liste e aggiorna la UI
  void _unisciEOrdina() {
    List<PrenotazioneModel> temp = [
      ..._listaPrenotazioniStandard,
      ..._listaSfideAccettate,
      ..._listaSfideMieCreate // NUOVA
    ];

    temp = temp.where((p) => p.stato != 'Conclusa').toList();

    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    temp = temp.where((p) {
      if (p.stato == 'Annullato') {
        final pDate = DateTime(p.data.year, p.data.month, p.data.day);
        return !pDate.isBefore(today);
      }
      return true;
    }).toList();

    // Ordinamento cronologico
    temp.sort((a, b) {
      int cmp = a.data.compareTo(b.data);
      if (cmp == 0) return a.ora.compareTo(b.ora);
      return cmp;
    });

    setState(() {
      _listaUnificata = temp;
      _isLoading = false;
    });
  }

  String _getDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Annulla / Concludi

  Future<void> _annullaPrenotazione(PrenotazioneModel p) async {
    bool isSfidaAccettata = _listaSfideAccettate.any((s) => s.id == p.id);
    bool isSfidaMiaCreata = _listaSfideMieCreate.any((s) => s.id == p.id);

    DateTime dataBase = p.data;
    DateTime dataOraReale;
    try {
      List<String> parts = p.ora.split(':');
      dataOraReale = DateTime(dataBase.year, dataBase.month, dataBase.day, int.parse(parts[0]), int.parse(parts[1]));
    } catch (e) {
      dataOraReale = p.data;
    }

    if (dataOraReale.isBefore(DateTime.now().add(const Duration(hours: 1)))) {
      CustomSnackBar.show(context, AppLocalizations.of(context)!.translate("Troppo tardi! Serve almeno 1 ora di preavviso."));
      return;
    }

    String messaggioConferma;
    if (isSfidaAccettata) {
      messaggioConferma = AppLocalizations.of(context)!.translate("Vuoi ritirarti dalla sfida?");
    } else if (isSfidaMiaCreata) {
      messaggioConferma = AppLocalizations.of(context)!.translate("Vuoi annullare la sfida?");
    } else {
      messaggioConferma = AppLocalizations.of(context)!.translate("Vuoi annullare la prenotazione?");
    }

    bool conferma = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate("Annulla")),
        content: Text(messaggioConferma),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppLocalizations.of(context)!.translate("No"))
          ),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(AppLocalizations.of(context)!.translate("Sì, annulla"), style: const TextStyle(color: Colors.red))
          ),
        ],
      ),
    ) ?? false;

    if (!conferma) return;

    try {
      if (isSfidaAccettata) {
        // Se è una sfida di qualcun altro che avevo accettato, mi ritiro.
        await FirebaseFirestore.instance.collection('sfide').doc(p.id).update({
          'stato': 'aperta',
          'opponentId': null,
          'opponentName': null
        });
        if (mounted) CustomSnackBar.show(context, AppLocalizations.of(context)!.translate("Ti sei ritirato dalla sfida."));
      } else if (isSfidaMiaCreata) {
        // Se è una sfida creata da me, la annullo completamente
        await FirebaseFirestore.instance.collection('sfide').doc(p.id).update({'stato': 'annullata'});
        if (mounted) CustomSnackBar.show(context, AppLocalizations.of(context)!.translate("Sfida annullata."));
      } else {
        // Se è una mia prenotazione normale, la annullo
        await FirebaseFirestore.instance.collection('prenotazioni').doc(p.id).update({'stato': 'Annullato'});

        var sfidaQuery = await FirebaseFirestore.instance
            .collection('sfide')
            .where('prenotazioneId', isEqualTo: p.id)
            .get();

        for (var doc in sfidaQuery.docs) {
          await doc.reference.delete();
        }

        if (mounted) CustomSnackBar.show(context, AppLocalizations.of(context)!.translate("Prenotazione annullata."));
      }
    } catch (e) {
      if (mounted) CustomSnackBar.show(context, "${AppLocalizations.of(context)!.translate("Errore: ")}$e");
    }
  }

  Future<void> _onPartitaConclusa(PrenotazioneModel p) async {
    // Capisco da quale lista proviene per aggiornare la collection giusta
    bool isSfidaAccettata = _listaSfideAccettate.any((s) => s.id == p.id);
    bool isSfidaMiaCreata = _listaSfideMieCreate.any((s) => s.id == p.id);

    String collection;
    if (isSfidaAccettata || isSfidaMiaCreata) {
      collection = 'sfide';
    } else {
      collection = 'prenotazioni';
    }

    try {
      await FirebaseFirestore.instance.collection(collection).doc(p.id).update({'stato': 'Conclusa'});
      if (mounted) CustomSnackBar.show(context, AppLocalizations.of(context)!.translate("Partita archiviata!"));
    } catch (e) {
      if (mounted) CustomSnackBar.show(context, "${AppLocalizations.of(context)!.translate("Errore: ")}$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (currentUserId.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.translate("Effettua il login per vedere le prenotazioni")));
    }

    if (_isLoading) {
      return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
    }

    // --- PREPARAZIONE DATI PER IL CALENDARIO ---
    Map<String, List<PrenotazioneModel>> mappaPrenotazioni = {};
    for (var p in _listaUnificata) {
      String key = _getDateKey(p.data);
      if (!mappaPrenotazioni.containsKey(key)) {
        mappaPrenotazioni[key] = [];
      }
      mappaPrenotazioni[key]!.add(p);
    }

    // Funzione conteggio pallini
    int countPrenotazioniFast(DateTime date) {
      String key = _getDateKey(date);
      if (mappaPrenotazioni.containsKey(key)) {
        return mappaPrenotazioni[key]!.where((p) => p.stato != "Annullato").length;
      }
      return 0;
    }

    // Lista da mostrare oggi
    String selectedKey = _getDateKey(_selectedDate);
    List<PrenotazioneModel> daMostrareOggi = mappaPrenotazioni[selectedKey] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
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
        if (daMostrareOggi.isEmpty)
          noPrenotazioni()
        else
          ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daMostrareOggi.length,
            itemBuilder: (context, index) {
              return PrenotazioneCard(
                prenotazione: daMostrareOggi[index],
                onAnnulla: _annullaPrenotazione,
                onPartitaConclusa: _onPartitaConclusa,
              );
            },
          ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}