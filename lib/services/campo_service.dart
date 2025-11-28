import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/CampoModel.dart';

class CampoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ottiene lo stream di tutti i campi
  Stream<List<CampoModel>> getCampi() {
    return _firestore.collection('campi').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CampoModel.fromSnapshot(doc)).toList();
    });
  }
}