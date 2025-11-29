import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../model/support/Constants.dart';

class Notizia {
  final String titolo;
  final String descrizione;
  final String urlImmagine;
  final String fonte;
  final String urlArticolo;

  Notizia({
    required this.titolo,
    required this.descrizione,
    required this.urlImmagine,
    required this.fonte,
    required this.urlArticolo,
  });

  factory Notizia.fromJson(Map<String, dynamic> json) {
    return Notizia(
      titolo: json['title'] ?? '',
      descrizione: json['description'] ?? '',
      urlImmagine: json['image'],
      fonte: json['source']?['name'] ?? '',
      urlArticolo: json['url'] ?? '',
    );
  }
}

List<Notizia> _parseNews(String responseBody) {
  final Map<String, dynamic> data = json.decode(responseBody);
  final List<dynamic> articlesJson = data['articles'] ?? [];

  return articlesJson
      .map((json) => Notizia.fromJson(json))
      .toList();
}

// Funzione principale per il recupero delle notizie
Future<List<Notizia>> fetchNews(String languageCode) async {
  String baseQuery = 'tennis';
  String context = '(ATP OR WTA OR "Davis Cup" OR "Grand Slam" OR Wimbledon OR "Roland Garros" OR "US Open" OR "Australian Open")';
  String exclusions = 'NOT "table tennis" NOT "ping pong" NOT padel NOT audience NOT ascolti NOT tv';
  final String query = '$baseQuery AND $context $exclusions';
  final String lang = languageCode;
  //di default magari meglio prendere quella del telefono
  //in modo smart, si potrebbe far cambiare dal menù in app bar
  final String sortby = 'publishedAt';

  // Calcola la data di una settimana fa per il filtro 'from'
  final DateTime now = DateTime.now();
  final DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));
  final String fromDate = sevenDaysAgo.toIso8601String().substring(0, 10);

  final url = Uri.parse('$Constants.API_GNEWS_URL?q=$query&lang=$lang&from=$fromDate&sortby=$sortby&token=$Constants.APIKEY_GNEWS');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    return compute(_parseNews, response.body);
  } else {
    return [];
  }
}