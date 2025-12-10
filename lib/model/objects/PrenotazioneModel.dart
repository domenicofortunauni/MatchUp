import 'package:cloud_firestore/cloud_firestore.dart';

class PrenotazioneModel {
  final String id;
  final String nomeStruttura;
  final String campo;
  final DateTime data;
  final String ora;
  final int durata;
  final double prezzo;
  final String stato;

  PrenotazioneModel({
    required this.id,
    required this.nomeStruttura,
    required this.campo,
    required this.data,
    required this.ora,
    required this.durata,
    required this.prezzo,
    required this.stato,
  });

  factory PrenotazioneModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime dataEvento = DateTime.now();
    //serve per mettere la data in formato firebase col timestamp
    if (data['data'] != null) {
      dataEvento = (data['data'] as Timestamp).toDate();
    }
    return PrenotazioneModel(
      id: doc.id,
      nomeStruttura: data['nomeStruttura'] ?? 'Struttura sconosciuta',
      campo: data['nomeSottoCampo'] ?? 'Campo',
      data: dataEvento,
      ora: data['oraInizio'] ?? '00:00',
      durata: data['durataMinuti'] ?? 60,
      prezzo: (data['prezzoTotale'] ?? 0).toDouble(),
      stato: data['stato'] ?? "Confermato",
    );
  }
}
