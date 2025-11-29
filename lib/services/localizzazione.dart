import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Ottiene la provincia corrente o ritorna Roma in caso di errore
  static Future<String> getCurrentCity({String defaultCity = 'Roma'}) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          return defaultCity;
        }
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return defaultCity;
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best );

      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude
      );

      if (placemarks.isNotEmpty) {
        //andrebbe visto all'estero come traduce "Provincia di " :/..
        return placemarks.first.subAdministrativeArea?.replaceFirst("Provincia di ", "") ??
            placemarks.first.locality ??
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
