import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../model/objects/PrenotazioneModel.dart';

class PrenotazioniHelper {
  String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  List<PrenotazioneModel> listaPrenotazioniStandard = [];
  List<PrenotazioneModel> listaSfideAccettate = [];
  List<PrenotazioneModel> listaSfideMieCreate = [];
  List<PrenotazioneModel> listaUnificata = [];
  StreamSubscription? subPrenotazioni;
  StreamSubscription? subSfide;
  StreamSubscription? subSfideMieCreate;
  bool isLoading = true;

  void inizializzaStreams(VoidCallback onUpdate) {
    DateTime now = DateTime.now();
    DateTime start = now.subtract(const Duration(days: 30));
    DateTime end = now.add(const Duration(days: 60));

    subPrenotazioni = FirebaseFirestore.instance
        .collection('prenotazioni')
        .where('userId', isEqualTo: currentUserId)
        .where('data', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('data', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('data')
        .snapshots()
        .listen((snapshot) {
      listaPrenotazioniStandard = snapshot.docs
          .where((doc) => doc.data()['tipo'] != 'sfida')
          .map((doc) => PrenotazioneModel.fromSnapshot(doc))
          .toList();
      _unisciEOrdina(onUpdate);
    });

    subSfide = FirebaseFirestore.instance
        .collection('sfide')
        .where('opponentId', isEqualTo: currentUserId)
        .where('stato', isEqualTo: 'accettata')
        .where('data', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('data', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .snapshots()
        .listen((snapshot) {
      listaSfideAccettate = snapshot.docs.map((doc) {
        final data = doc.data();
        return PrenotazioneModel(
          id: doc.id,
          nomeStruttura: data['nomeStruttura'] ?? "Sfida",
          campo: "Sfida vs ${data['challengerName'] ?? ""}",
          data: (data['data'] as Timestamp).toDate(),
          ora: data['ora'] ?? "00:00",
          durata: data['durataMinuti'] ?? 90,
          prezzo: 0.0,
          stato: "Confermato",
        );
      }).toList();
      _unisciEOrdina(onUpdate);
    });

    subSfideMieCreate = FirebaseFirestore.instance
        .collection('sfide')
        .where('challengerId', isEqualTo: currentUserId)
        .where('stato', isEqualTo: 'accettata')
        .where('data', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('data', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .snapshots()
        .listen((snapshot) {
      listaSfideMieCreate = snapshot.docs.map((doc) {
        final data = doc.data();
        return PrenotazioneModel(
          id: doc.id,
          nomeStruttura: data['nomeStruttura'] ?? "Sfida",
          campo: "Sfida vs ${data['opponentName'] ?? ""}",
          data: (data['data'] as Timestamp).toDate(),
          ora: data['ora'] ?? "00:00",
          durata: data['durataMinuti'] ?? 90,
          prezzo: 0.0,
          stato: "Confermato",
        );
      }).toList();
      _unisciEOrdina(onUpdate);
    });
  }

  void _unisciEOrdina(VoidCallback onUpdate) {
    List<PrenotazioneModel> temp = [
      ...listaPrenotazioniStandard,
      ...listaSfideAccettate,
      ...listaSfideMieCreate,
    ];
    temp = temp.where((p) => p.stato != 'Conclusa').toList();
    final today = DateTime.now();
    temp = temp.where((p) {
      if (p.stato == 'Annullato') {
        final d = DateTime(p.data.year, p.data.month, p.data.day);
        return !d.isBefore(DateTime(today.year, today.month, today.day));
      }
      return true;
    }).toList();
    temp.sort((a, b) {
      final c = a.data.compareTo(b.data);
      if (c != 0) return c;
      return a.ora.compareTo(b.ora);
    });
    listaUnificata = temp;
    isLoading = false;
    onUpdate();
  }

  void dispose() {
    subPrenotazioni?.cancel();
    subSfide?.cancel();
    subSfideMieCreate?.cancel();
  }
}