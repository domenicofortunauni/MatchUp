import 'package:cloud_firestore/cloud_firestore.dart';

class PartitaModel {
  final String avversario;
  final int gameVinti;
  final int gamePersi;
  final int setVinti;
  final int setPersi;
  final DateTime data;
  final List<String> punteggio;

  factory PartitaModel.fromFirestore(Map<String, dynamic> data) {
    return PartitaModel(
      avversario: data['avversario'] ?? '',
      gameVinti: (data['gameVinti'] as num?)?.toInt() ?? 0,
      gamePersi: (data['gamePersi'] as num?)?.toInt() ?? 0,
      setVinti: (data['setVinti'] as num?)?.toInt() ?? 0,
      setPersi: (data['setPersi'] as num?)?.toInt() ?? 0,
      data: (data['data'] as Timestamp?)?.toDate() ?? DateTime.now(),
      punteggio: List<String>.from(data['punteggio'] ?? []),
    );
  }
  bool get isVittoria => setVinti > setPersi;
  const PartitaModel({
    required this.avversario,
    required this.gameVinti,
    required this.gamePersi,
    required this.setVinti,
    required this.setPersi,
    required this.data,
    required this.punteggio,
  });
}

class SetScore {
  final int me;
  final int opponent;
  SetScore(this.me, this.opponent);
}