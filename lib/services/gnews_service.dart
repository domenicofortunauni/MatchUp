import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/objects/NotiziaModel.dart';
import '../model/support/Constants.dart';

List<NotiziaModel> _parseNews(String responseBody) {
  final Map<String, dynamic> data = json.decode(responseBody);
  final List<dynamic> articlesJson = data['articles'] ?? [];
  return articlesJson
      .map((json) => NotiziaModel.fromJson(json))
      .toList();
}

String getImmagineDefaultRandom(NotiziaModel notizia) {
  const int numeroImmagini = 10;
  int uniqueId = notizia.titolo.hashCode.abs();
  int imageNumber = (uniqueId % numeroImmagini) + 1;
  return 'assets/images/immagini_news/defaultNews$imageNumber.jpg';
}
Future<void> launchURL(String urlString) async {
  final Uri url = Uri.parse(urlString);
  //serve per aprire il browser del telefono
  try {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Non riesco ad aprire il link: $urlString');
    }
  } catch (e) {
    debugPrint('Errore nell\'apertura del link: $e');
  }
}
// Funzione per il recupero delle notizie
Future<List<NotiziaModel>> fetchNews(String languageCode) async {
  String keyTennis = '(ATP OR WTA OR "Davis Cup" OR "Grand Slam" OR Wimbledon OR "Roland Garros" OR "US Open" OR "Australian Open")';
  String listaEsclusioni = 'NOT "table tennis" NOT "ping pong" NOT padel NOT audience NOT ascolti NOT tv';
  final String query = 'tennis AND $keyTennis $listaEsclusioni';
  final String lang = languageCode; //passata dalla lingua corrente
  final String sortby = 'publishedAt';
  final DateTime now = DateTime.now();
  final DateTime setteGiorniFa = now.subtract(const Duration(days: 7));
  final String fromDate = setteGiorniFa.toString().substring(0, 10);

  final url = Uri.parse('${Constants.API_GNEWS_URL}?q=$query&lang=$lang&from=$fromDate&sortby=$sortby&token=${Constants.APIKEY_GNEWS}');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return compute(_parseNews, response.body);
  } else {
    return [];
  }
}