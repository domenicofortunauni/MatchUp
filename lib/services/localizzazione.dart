import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Ottiene la città corrente o ritorna una città di default in caso di errore
  static Future<String> getCurrentCity({String defaultCity = 'Roma'}) async {
    try {
      // Controllo Permessi geoloc
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          return defaultCity;
        }
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return defaultCity;
      final position = await Geolocator.getCurrentPosition();

      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude
      );

      if (placemarks.isNotEmpty) {
        return placemarks.first.locality ??
            placemarks.first.subAdministrativeArea ??
            defaultCity;
      }
      return defaultCity;
    } catch (e) {
      return defaultCity;
    }
  }
  static Future<Position?> getCurrentPosition() async {
    try {
      //Controllo Permessi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          return null;
        }
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      // Ottieni Posizione
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return null;
    }
  }
}
