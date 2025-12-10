import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/objects/CampoModel.dart';

class CampoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // restituisce la lista di tutti i campi della città passata come parametro sortati per rating
  Stream<List<CampoModel>> getCampi(String userCitta) {
    //metto col formato col quale le salvo nel db es. Rende
    final cittaFormatoDB = userCitta[0].toUpperCase() + userCitta.substring(1).toLowerCase();
    return _firestore
        .collection('campi')
        .where('citta', isEqualTo: cittaFormatoDB)
        .orderBy('rating', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CampoModel.fromSnapshot(doc))
        .toList());
  }
}