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
import 'dart:async'; // Necessario per StreamSubscription

class PrenotazioniWidget extends StatefulWidget {
  const PrenotazioniWidget({Key? key}) : super(key: key);

  @override
  State<PrenotazioniWidget> createState() => _PrenotazioniWidgetState();
}

class _PrenotazioniWidgetState extends State<PrenotazioniWidget> with AutomaticKeepAliveClientMixin {
  DateTime _selectedDate = DateTime.now();
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  // Liste locali per gestire i due flussi di dati
  List<Prenotazione> _listaPrenotazioniStandard = [];
  List<Prenotazione> _listaSfideAccettate = [];
  List<Prenotazione> _listaUnificata = [];

  // Sottoscrizioni ai flussi
  StreamSubscription? _subPrenotazioni;
  StreamSubscription? _subSfide;

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
    super.dispose();
  }

  void _inizializzaStreams() {
    DateTime now = DateTime.now();
    DateTime start = now.subtract(const Duration(days: 30));
    DateTime end = now.add(const Duration(days: 60));

    //STREAM PRENOTAZIONI (Quelle create da me)
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
            .map((doc) => Prenotazione.fromSnapshot(doc))
            .toList();
        _unisciEOrdina();
      });
    });

    //STREAM SFIDE (Quelle create da ALTRI e accettate da ME)
    _subSfide = FirebaseFirestore.instance
        .collection('sfide')
        .where('opponentId', isEqualTo: currentUserId) // Dove sono l'avversario
        .where('stato', isEqualTo: 'accettata')        // Solo confermate
        .where('data', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('data', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .snapshots()
        .listen((snapshot) {

      setState(() {
        _listaSfideAccettate = snapshot.docs.map((doc) {
          // CONVERTO LA SFIDA IN PRENOTAZIONE
          final data = doc.data();
          String nomeStruttura = data['nomeStruttura'] ?? "Sfida";
          String challengerName = data['challengerName'] ?? "";

          return Prenotazione(
              id: doc.id,
              nomeStruttura: nomeStruttura,
              campo: "Sfida vs $challengerName", // "Sfida vs" lo lascio così o lo gestisco nella card
              data: (data['data'] as Timestamp).toDate(),
              ora: data['ora'] ?? "00:00",
              durata: 90, // Durata standard sfida se non specificata (es. 90 min)
              prezzo: 0.0, // Non sappiamo il prezzo se paga l'altro, mettiamo 0 o gestisci
              stato: "Confermato"
          );
        }).toList();
        _unisciEOrdina();
      });
    });
  }

  // Unisce le due liste e aggiorna la UI
  void _unisciEOrdina() {
    List<Prenotazione> temp = [..._listaPrenotazioniStandard, ..._listaSfideAccettate];

    // Filtro eventuali doppioni (non dovrebbero esserci per logica, ma sicurezza) o partite concluse
    temp = temp.where((p) => p.stato != 'Conclusa').toList();

    // Filtro Annullate vecchie
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    temp = temp.where((p) {
      if (p.stato == 'Annullato') {
        final pDate = DateTime(p.data.year, p.data.month, p.data.day);
        return !pDate.isBefore(today); // Nascondi annullate passate
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

  // --- AZIONI (Annulla / Concludi) ---

  Future<void> _annullaPrenotazione(Prenotazione p) async {
    //Capisco se è una sfida accettata (non mia) o una prenotazione mia
    bool isSfidaAccettata = _listaSfideAccettate.any((s) => s.id == p.id);

    //Controllo Orario Limite
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

    //Chiedo Conferma
    bool conferma = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate("Annulla")),
        content: Text(isSfidaAccettata
            ? AppLocalizations.of(context)!.translate("Vuoi ritirarti dalla sfida?")
            : AppLocalizations.of(context)!.translate("Vuoi annullare la prenotazione?")),
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

    //Eseguo l'azione corretta su Firebase
    try {
      if (isSfidaAccettata) {
        // Se è una sfida di qualcun altro che avevo accettato, mi ritiro.
        // La sfida torna "aperta" e senza opponent.
        await FirebaseFirestore.instance.collection('sfide').doc(p.id).update({
          'stato': 'aperta',
          'opponentId': null,
          'opponentName': null
        });
        if (mounted) CustomSnackBar.show(context, AppLocalizations.of(context)!.translate("Ti sei ritirato dalla sfida."));
      } else {
        // Se è una mia prenotazione (o una sfida creata da me), la annullo.
        await FirebaseFirestore.instance.collection('prenotazioni').doc(p.id).update({'stato': 'Annullato'});

        // Se era una mia sfida, devo anche chiudere la sfida pubblica collegata (se esiste)
        // Cerco se c'è una sfida collegata a questa prenotazione
        var sfidaQuery = await FirebaseFirestore.instance
            .collection('sfide')
            .where('prenotazioneId', isEqualTo: p.id)
            .get();

        for (var doc in sfidaQuery.docs) {
          await doc.reference.delete(); // Cancello la sfida pubblica perché non ho più il campo
        }

        if (mounted) CustomSnackBar.show(context, AppLocalizations.of(context)!.translate("Prenotazione annullata."));
      }
    } catch (e) {
      if (mounted) CustomSnackBar.show(context, "${AppLocalizations.of(context)!.translate("Errore: ")}$e");
    }
  }

  Future<void> _onPartitaConclusa(Prenotazione p) async {
    // Logica simile per archiviare
    bool isSfidaAccettata = _listaSfideAccettate.any((s) => s.id == p.id);
    String collection = isSfidaAccettata ? 'sfide' : 'prenotazioni';

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
    Map<String, List<Prenotazione>> mappaPrenotazioni = {};
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
    List<Prenotazione> daMostrareOggi = mappaPrenotazioni[selectedKey] ?? [];

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
        //calendario scorrevole
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
        //se non ho prenotazioni nel giorno corrente mostro un windget ad hoc
        if (daMostrareOggi.isEmpty)
            noPrenotazioni()
        else //se ho prenotazioni costruisco la vista con le card
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