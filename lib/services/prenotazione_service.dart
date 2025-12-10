import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PrenotazioneService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // Scarica orari occupati
  Future<Map<String, Set<int>>> getOrariOccupati(String campoId, DateTime date) async
  {
    String dataString = DateFormat('yyyy-MM-dd').format(date);
    final snapshot = await _db.collection('prenotazioni')
        .where('campoId', isEqualTo: campoId)
        .where('dataString', isEqualTo: dataString)
        .get();

    Map<String, Set<int>> occupati = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      String nomeSottoCampo = data['nomeSottoCampo'] ?? ''; //sarebbe il campo scelto
      String oraInizio = data['oraInizio'] ?? '00:00';
      int durata = data['durataMinuti'] ?? 0;

      if (nomeSottoCampo.isNotEmpty) {
        if (!occupati.containsKey(nomeSottoCampo)) {
          occupati[nomeSottoCampo] = {};
          //serve a inizializzare la lista degli orari occupati del campo dove finiranno gli orari occupati come interi
        }
        // Conversione orario in minuti
        final parts = oraInizio.split(':'); //orario in formato ore:minuti, uso regex
        int startMin = int.parse(parts[0]) * 60 + int.parse(parts[1]);
        int slots = durata ~/ 30; //divisione intera in dart
        for (int i = 0; i < slots; i++) {
          occupati[nomeSottoCampo]!.add(startMin + (i * 30));
        }
      }
    }
    return occupati;
  }

  // Salva prenotazione
  Future<void> creaPrenotazione({
    required String uid,
    required String nomeUtente,
    required String campoId,
    required String nomeStruttura,
    required String indirizzo,
    required String nomeSottoCampo,
    required DateTime data,
    required String oraInizio,
    required int durata,
    required double prezzo,
  }) async {
    await _db.collection('prenotazioni').add({
      'userId': uid,
      'userName': nomeUtente,
      'campoId': campoId,
      'nomeStruttura': nomeStruttura,
      'nomeSottoCampo': nomeSottoCampo,
      'indirizzo': indirizzo,
      'data': Timestamp.fromDate(data),
      'dataString': DateFormat('yyyy-MM-dd').format(data),
      'oraInizio': oraInizio,
      'durataMinuti': durata,
      'prezzoTotale': prezzo,
      'timestampCreazione': FieldValue.serverTimestamp(),
    });
  }
}