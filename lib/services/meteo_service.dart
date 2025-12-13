import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/support/Constants.dart';

class MeteoService {

  /// Restituisce true se nella città è prevista pioggia
  static Future<bool> isRainExpected(String city, DateTime date) async {
    try {
      final url = Uri.parse("${Constants.API_METEO_URL}?q=$city&units=metric&appid=${Constants.APIKEY_METEO}&lang=it");
      final response = await http.get(url);

      if (response.statusCode != 200)
        return false;

      final Map<String, dynamic> jsonData = json.decode(response.body);

      final List<dynamic> forecasts = jsonData['list'] ?? [];

      for (var f in forecasts) {
        final dt = DateTime.fromMillisecondsSinceEpoch(f['dt'] * 1000);
        if (dt.day == date.day && dt.month == date.month && dt.year == date.year) {
          final weather = f['weather'] as List<dynamic>;
          if (weather.isNotEmpty) {
            final main = weather[0]['main'].toString().toLowerCase();
            if (main.contains('rain') || main.contains('drizzle') || main.contains('thunderstorm')) {
              return true;
            }
          }
        }
      }
      return false;
    } catch (e) {
      print("Errore MeteoService: $e");
      return false;
    }
  }
}
