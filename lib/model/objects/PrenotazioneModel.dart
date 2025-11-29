import 'package:cloud_firestore/cloud_firestore.dart';

class Prenotazione {
  final String id;
  final String nomeStruttura;
  final String campo;
  final DateTime data;
  final String ora;
  final int durata;
  final double prezzo;
  final String stato;

  Prenotazione({
    required this.id,
    required this.nomeStruttura,
    required this.campo,
    required this.data,
    required this.ora,
    required this.durata,
    required this.prezzo,
    required this.stato,
  });

  factory Prenotazione.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime dataEvento = DateTime.now();

    // Gestione Timestamp di Firebase
    if (data['data'] != null) {
      dataEvento = (data['data'] as Timestamp).toDate();
    }

    return Prenotazione(
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
