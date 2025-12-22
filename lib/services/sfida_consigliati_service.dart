import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String myUid = FirebaseAuth.instance.currentUser?.uid ?? "";
  int _getLevelScore(String level) {
    String l = level.toLowerCase().trim();
    if (l.contains('amatoriale')) return 1;
    if (l.contains('dilettante')) return 2;
    if (l.contains('intermedio')) return 3;
    if (l.contains('avanzato'))return 4;
    if (l.contains('professionista')) return 5;
    return 0;
  }
  Future<List<Map<String, dynamic>>> getSuggestedPlayers() async {
    try {
      final myProfileSnapshot = await _db.collection('users').doc(myUid).get();
      final myData = myProfileSnapshot.data() ?? {};

      final String miaCitta = (myData['citta'] ?? '').toString();
      final String mioLivello = (myData['livello'] ?? "").toString();
      final int mioPunteggio = _getLevelScore(mioLivello);

      final utenti = await _db.collection('users').limit(100).get();
      List<Map<String, dynamic>> results = [];

      for (var doc in utenti.docs) {
        if (doc.id == myUid) continue;
        final data = doc.data();
        data['uid'] = doc.id;
        final String userCitta = (data['citta'] ?? '').toString();
        final String userLivello = (data['livello'] ?? "").toString();
        final int userPunteggio = _getLevelScore(userLivello);

        //Logica vicinanza
        bool isNear = (miaCitta.isNotEmpty && userCitta.toLowerCase() == miaCitta.toLowerCase());
        //Logica rank -- Rosso se più alto, blu se stesso rank o minore
        String levelStatus = (userPunteggio > mioPunteggio+1 || userPunteggio<mioPunteggio-1) ? 'high' : 'ok';

        //logica per ordinarli come suggerita dal prof al ricevimento
        int sortGroup;
        bool sfidaUpLevel = userPunteggio == mioPunteggio+1; // sfida per temerari
        bool sfidaDownLevel = userPunteggio == mioPunteggio-1; //sfida conservativa

        if (isNear && sfidaUpLevel) sortGroup = 0;
        else if (isNear && userPunteggio == mioPunteggio) sortGroup = 1;
        else if (isNear && sfidaDownLevel) sortGroup = 2;
        else if (isNear) sortGroup = 3;
        else if (!isNear && sfidaUpLevel) sortGroup = 4;
        else if (!isNear && userPunteggio == mioPunteggio) sortGroup = 5;
        else if (!isNear && sfidaDownLevel) sortGroup = 6;
        else sortGroup = 7; // non vicino & livello maggiore/inferiore di 2
        //aggiungo sti dati alla mappa di results
        data['priority'] = isNear ? 1 : 0;
        data['sort_group'] = sortGroup;
        data['level_status'] = levelStatus;
        data['level_score'] = userPunteggio;
        data['livello'] = userLivello;
        results.add(data);
      }
      results.sort((a, b) {
        // Prima per sort_group
        int cmp = (a['sort_group'].compareTo(b['sort_group']));
        if (cmp != 0) return cmp;
        // Poi a parità per avversario più facile
        return (a['level_score'].compareTo(b['level_score']));
      });
      return results;

    } catch (e) {
      print("Errore suggerimenti: $e");
      return [];
    }
  }
}