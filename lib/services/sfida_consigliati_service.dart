import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String myUid = FirebaseAuth.instance.currentUser!.uid;

  Future<List<Map<String, dynamic>>> getSuggestedPlayers() async {
    try {
      final myProfileSnapshot = await _db.collection('users').doc(myUid).get();
      final myData = myProfileSnapshot.data() ?? {};
      final String myCity = myData['citta'] ?? '';

      final query = await _db.collection('users').limit(20).get();
      List<Map<String, dynamic>> results = [];

      for (var doc in query.docs) {
        if (doc.id == myUid) continue;
        final data = doc.data();
        final String userCity = data['citta'] ?? '';
        // Se condividiamo la città lo porto sopra
        bool isNear = (myCity.isNotEmpty && userCity == myCity);
        //Serve per gestire il campo verde UI "vicino a te" in NuovaChatPopup
        data['ui_tag'] = isNear ? "Vicino a te" : "Consigliato";
        data['priority'] = isNear ? 1 : 0; // 1 = Alta priorità
        results.add(data);
      }
      //Sort per stessa città
      results.sort((a, b) => b['priority'].compareTo(a['priority']));
      return results;

    } catch (e) {
      print("Errore suggerimenti: $e");
      return [];
    }
  }
}