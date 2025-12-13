import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LocationService {
  static Future<String> getCurrentCity({String defaultCity = 'Roma'}) async {

    final Position? location = await getCurrentPosition();
      if (location != null) {
          final url = Uri.parse(
              "https://nominatim.openstreetmap.org/reverse?format=json&lat=${location.latitude}&lon=${location.longitude}"
              //usiamo questo perché geocoding non funziona da PC
          );
          final res = await http.get(
            url,
            headers: {
              "User-Agent": "FlutterApp/1.0 (MatchUP)"
            },
          );
          if (res.statusCode == 200) {
            final data = jsonDecode(res.body);
            return data["address"]["city"] ??
                data["address"]["town"] ??
                data["address"]["village"];
          }
      }
    return defaultCity;
  }

  static Future<Position?> getCurrentPosition() async {
      if(await checkPermission()){
        return await Geolocator.getCurrentPosition();
      }
    return null;
    }

  static Future<bool> checkPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return false;
        }
      }
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

    } catch (e) {
      return false;
    }
    return true;
  }
  static Future<String> getMyCity() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        return data['citta'];
      }
    } catch (e) {
      print('Errore nel recupero dati utente: $e');
    }
    return '';
  }
}