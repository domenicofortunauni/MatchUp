import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SfidaModel {
  final String id;
  final String challengerId;
  final String challengerName;
  final String nomeStruttura;
  final String dataOra;
  final String livello;
  final String? opponentId;   // Null finché non accettata
  final String? opponentName;
  final String? modalita;     // puo' essere pubblica o diretta

  SfidaModel({
    required this.id,
    required this.challengerId,
    required this.challengerName,
    required this.nomeStruttura,
    required this.dataOra,
    required this.livello,
    this.opponentId,
    this.opponentName,
    this.modalita,
  });

  factory SfidaModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    String dataLeggibile = "";
    if (data['data'] != null) {
      DateTime dt = (data['data'] as Timestamp).toDate();
      dataLeggibile = DateFormat('dd/MM').format(dt);
    }
    String ora = data['ora'] ?? "";

    return SfidaModel(
      id: doc.id,
      challengerId: data['challengerId'] ?? '',
      challengerName: data['challengerName'] ?? 'Sconosciuto',
      nomeStruttura: data['nomeStruttura'] ?? 'Campo',
      dataOra: "$dataLeggibile - $ora",
      livello: data['livello'] ?? 'Amatoriale',
      opponentId: data['opponentId'],
      opponentName: data['opponentName'],
      modalita: data['modalita'],
    );
  }
}