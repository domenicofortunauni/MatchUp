import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;


class LocationService {
  static Future<String> getCurrentCity({String defaultCity = 'Roma'}) async {

    final Position? location = await getCurrentPosition();
      if (location != null) {
          final url = Uri.parse(
              "https://nominatim.openstreetmap.org/reverse?format=json&lat=${location.latitude}&lon=${location.longitude}"
          );
          final res = await http.get(url);
          if (res.statusCode == 200) {
            final data = jsonDecode(res.body);
            return data["address"]["town"] ??
                data["address"]["city"] ??
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
}