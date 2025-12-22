import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import 'package:matchup/UI/widgets/HorizontalWeekCalendar.dart';
import 'package:matchup/UI/widgets/CustomSnackBar.dart';
import '../../../model/objects/PrenotazioneModel.dart';
import '../../../services/prenotazione_helper.dart';
import '../EmptyWidget.dart';
import '../cards/PrenotazioneCard.dart';
import 'dart:async';
import 'package:matchup/services/notification_service.dart';

import '../dialogs/annullaSfidaDialog.dart';

class PrenotazioniWidget extends StatefulWidget {
  const PrenotazioniWidget({Key? key}) : super(key: key);
  @override
  State<PrenotazioniWidget> createState() => _PrenotazioniWidgetState();
}
class _PrenotazioniWidgetState extends State<PrenotazioniWidget> with AutomaticKeepAliveClientMixin {
  DateTime _selectedDate = DateTime.now();
  late PrenotazioniHelper helper;

  @override
  void initState() {
    super.initState();
    helper = PrenotazioniHelper();
    if (helper.currentUserId.isNotEmpty) {
      helper.inizializzaStreams(() {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    helper.dispose();
    super.dispose();
  }
  // Annulla / Concludi
  Future<void> _annullaPrenotazione(PrenotazioneModel p) async {
    bool isSfidaAccettata = helper.listaSfideAccettate.any((sfida) => sfida.id == p.id);
    bool isSfidaMiaCreata = helper.listaSfideMieCreate.any((sfida) => sfida.id == p.id);
    DateTime dataBase = p.data;
    DateTime dataOraPrenotazione;
    //verifica se è possibile annullare la prenotazione (almeno 1 ora prima)
    try {
      List<String> parts = p.ora.split(':');
      dataOraPrenotazione = DateTime(dataBase.year, dataBase.month, dataBase.day, int.parse(parts[0]), int.parse(parts[1]));
    } catch (e) {
      dataOraPrenotazione = p.data;
    }
    if (dataOraPrenotazione.isBefore(DateTime.now().add(const Duration(hours: 1)))) {
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
    bool conferma = await annullaSfidaDialog.showConfirmDialog(context,messaggioConferma);
    if (!conferma) return;
    try {
      if (isSfidaAccettata) {
      //Se è una sfida accettata, mi ritiro lasciandola aperta
        await FirebaseFirestore.instance.collection('sfide').doc(p.id).update({
          'stato': 'aperta',
          'opponentId': null,
          'opponentName': null
        });
        if (mounted) CustomSnackBar.show(context, AppLocalizations.of(context)!.translate("Ti sei ritirato dalla sfida."));
      } else if (isSfidaMiaCreata) {
        // Se è una sfida creata da me, la annullo completamente
        await FirebaseFirestore.instance.collection('sfide').doc(p.id).update({'stato': 'annullata'});
        var queryPrenotazioni = await FirebaseFirestore.instance
            .collection('prenotazioni')
            .where('userId', isEqualTo: helper.currentUserId)
            .where('oraInizio', isEqualTo: p.ora)
            .where('dataString', isEqualTo: DateFormat('yyyy-MM-dd').format(p.data))
            .get();
        for (var doc in queryPrenotazioni.docs) {
          await doc.reference.update({'stato': 'Annullato'});
          }
        if (mounted) CustomSnackBar.show(context, AppLocalizations.of(context)!.translate("Sfida annullata."));
      } else {
        // Se è una mia prenotazione, la annullo
        await FirebaseFirestore.instance.collection('prenotazioni').doc(p.id).update({'stato': 'Annullato'});
        await NotificationService().cancelNotification(p.id.hashCode.abs());
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
      if (mounted) CustomSnackBar.show(context, "${AppLocalizations.of(context)!.translate("Errore:")} $e");
    }
  }
  Future<void> _onPartitaConclusa(PrenotazioneModel p) async {
    // Capisco da quale lista proviene per aggiornare la collection giusta
    bool isSfidaAccettata = helper.listaSfideAccettate.any((sfida) => sfida.id == p.id);
    bool isSfidaMiaCreata = helper.listaSfideMieCreate.any((sfida) => sfida.id == p.id);

    String collection;
    isSfidaAccettata || isSfidaMiaCreata ? collection = 'sfide' : collection = 'prenotazioni';
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
    if (helper.isLoading) {
      return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
    }

    final Map<String, List<PrenotazioneModel>> mappaPrenotazioni = {};
    final Map<String, int> mappaCount = {};
    for (var prenotazione in helper.listaUnificata) {
      String key = DateFormat('yyyy-MM-dd').format(prenotazione.data);
      // Inizializza lista se non esistono delle prenotazioni per quel giorno
      if (!mappaPrenotazioni.containsKey(key)) {
        mappaPrenotazioni[key] = [];
      }
      mappaPrenotazioni[key]!.add(prenotazione);
      if (prenotazione.stato != "Annullato") {
        mappaCount[key] = (mappaCount[key] ?? 0) + 1;
      }
    }
    // Funzione conteggio prenotazioni per il badge del calendario
    int countPrenotazioni(DateTime date) {
      String key = DateFormat('yyyy-MM-dd').format(date);
      return mappaCount[key] ?? 0;
    }
    // Lista da mostrare oggi
    String selectedKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    List<PrenotazioneModel> daMostrareOggi = mappaPrenotazioni[selectedKey] ?? [];

    return Padding(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
            AppLocalizations.of(context)!.translate("Le tue prenotazioni"),
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
         HorizontalWeekCalendar(
            selectedDate: _selectedDate,
            showMonthHeader: true,
            allowPastDates: true,
            onDateChanged: (newDate) {
              setState(() {
                _selectedDate = newDate;
              });
            },
            eventCountProvider: countPrenotazioni,
          ),
        if (daMostrareOggi.isEmpty)
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child:Center(
                child:EmptyWidget(
                  text: AppLocalizations.of(context)!.translate("Nessuna prenotazione"),
                  subText: AppLocalizations.of(context)!.translate("Non hai partite in programma per oggi"),
                  icon: Icons.event_busy_rounded,
              ), )
          )
        else
          ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daMostrareOggi.length,
            itemBuilder: (context, index) {
              return PrenotazioneCard(
                prenotazione: daMostrareOggi[index],
                onAnnulla: _annullaPrenotazione,
                onPartitaConclusa: _onPartitaConclusa,
              );
            },),],));
  }
  @override
  bool get wantKeepAlive => true;
}