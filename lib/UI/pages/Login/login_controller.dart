import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/localizzazione.dart';

class LoginLogic {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  LoginLogic(this.auth, this.firestore);

  bool isUserLogged() {
    return auth.currentUser != null;
  }

  Future<void> login(String email, String password) async {
    final credential = await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    if (credential.user != null) {
      await updateUserCity();
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String nome,
    required String cognome,
    required String username,
    required String livello,
  }) async {
    final cred = await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final city = await LocationService.getCurrentCity();

    await firestore.collection('users').doc(cred.user!.uid).set({
      'nome': _formatName(nome),
      'cognome': _formatName(cognome),
      'username': username.trim(),
      'displayName': username.trim(),
      'email': email.trim(),
      'uid': cred.user!.uid,
      'livello': livello,
      'citta': city,
      'data_iscrizione': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUserCity() async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return;

    final city = await LocationService.getCurrentCity();
    await firestore.collection('users').doc(uid).update({'citta': city});
  }

  String _formatName(String text) {
    if (text.isEmpty) return "";
    final cleaned = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    return cleaned
        .split(' ')
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }
}
