import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/objects/PartitaModel.dart';
import '../model/objects/PrenotazioneModel.dart';

class TennisScoreService {
  PartitaModel validaPartita({
    required String avversario,
    required DateTime data,
    required List<SetScore> sets,
  }) {
    if (sets.isEmpty) {
      throw Exception("Inserisci almeno un set");
    }

    int gameVinti = 0;
    int gamePersi = 0;
    int setVinti = 0;
    int setPersi = 0;
    List<String> punteggio = [];

    for (int i = 0; i < sets.length; i++) {
      final me = sets[i].me;
      final opp = sets[i].opponent;

      if (me == opp) {
        throw Exception("Un set è in pareggio, non è valido");
      }

      final max = me > opp ? me : opp;
      final min = me < opp ? me : opp;

      if (max != 6 && max != 7) {
        throw Exception("Un set deve finire con 6 o 7 giochi vinti");
      }

      if (max == 6 && min == 5) {
        throw Exception("Un set non può finire 6-5");
      }

      if (max == 7 && (min != 5 && min != 6)) {
        throw Exception("Un set che finisce 7 deve avere l'avversario con 5 o 6 giochi");
      }

      gameVinti += me;
      gamePersi += opp;
      punteggio.add("$me-$opp");

      me > opp ? setVinti++ : setPersi++;
    }

    if (setVinti == setPersi) {
      throw Exception("La partita non può finire in parità");
    }

    return PartitaModel(
      avversario: avversario,
      gameVinti: gameVinti,
      gamePersi: gamePersi,
      setVinti: setVinti,
      setPersi: setPersi,
      data: data,
      punteggio: punteggio,
    );
  }

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> save(PartitaModel partita, PrenotazioneModel? prenotazione) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Utente non loggato");

    final data = {
      'userId': user.uid,
      'avversario': partita.avversario,
      'data': Timestamp.fromDate(partita.data),
      'gameVinti': partita.gameVinti,
      'gamePersi': partita.gamePersi,
      'setVinti': partita.setVinti,
      'setPersi': partita.setPersi,
      'isVittoria': partita.isVittoria,
      'punteggioStringa': partita.punteggio.join(' '),
      'prenotazioneId': prenotazione?.id,
      'nomeStruttura': prenotazione?.nomeStruttura ?? "",
      'campo': prenotazione?.campo ?? "",
      'timestamp_creazione': FieldValue.serverTimestamp(),
    };

    final batch = _db.batch();
    batch.set(_db.collection('partite').doc(), data);
    batch.set(_db.collection('statistiche').doc(), data);
    await batch.commit();
  }
}

