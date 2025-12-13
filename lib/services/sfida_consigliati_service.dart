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
        String levelStatus = (userPunteggio > mioPunteggio) ? 'high' : 'ok';

        //logica per ordinarli
        //prima i vicini stesso rank, poi ordinati in base al rank
        int sortGroup;
        if (isNear && userPunteggio == mioPunteggio) sortGroup = 0;
        else if (isNear && userPunteggio < mioPunteggio) sortGroup = 1;
        else if (isNear && userPunteggio > mioPunteggio) sortGroup = 2;
        else if (!isNear && userPunteggio == mioPunteggio) sortGroup = 3;
        else if (!isNear && userPunteggio < mioPunteggio) sortGroup = 4;
        else sortGroup = 5; // non vicino & livello maggiore
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
        // Tra i vicini livello minore o uguale , ordine decrescente per livello
        // Tra i non vicini stesso livello o minore, ordine decrescente per livello
        if (a['sort_group'] == 0 || a['sort_group'] == 1||a['sort_group'] == 3|| a['sort_group'] == 4)
          return b['level_score'].compareTo(a['level_score']);
        // Tra i vicini con livello maggiore o non vicini, ordine crescente per livello
         return a['level_score'].compareTo(b['level_score']);
      });
      return results;

    } catch (e) {
      print("Errore suggerimenti: $e");
      return [];
    }
  }
}