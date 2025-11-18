import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

// Chiave API e Base URL (rimangono invariati)
const String _apiKey = '470ca9d053c288330bf2c04403b58850';
const String _baseUrl = 'https://gnews.io/api/v4/search';

// Modello dei Dati per un Articolo (rimane invariato)
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
    String? imageUrl = json['image'];

    if (imageUrl == null || imageUrl.isEmpty) {
      imageUrl = 'assets/images/defaultNews.jpg';
    }

    return Notizia(
      titolo: json['title'] ?? 'Nessun Titolo',
      descrizione: json['description'] ?? 'Nessuna descrizione disponibile.',
      urlImmagine: imageUrl,
      fonte: json['source']?['name'] ?? 'Sconosciuta',
      urlArticolo: json['url'] ?? '',
    );
  }
}

// Funzione di Parsing Eseguita in Isolate (MODIFICATA)
List<Notizia> _parseNews(String responseBody) {
  final Map<String, dynamic> data = json.decode(responseBody);
  final List<dynamic> articlesJson = data['articles'] ?? [];

  // Mappa gli articoli e filtra per quelli che hanno una foto reale.
  return articlesJson
      .map((json) => Notizia.fromJson(json))
      .toList();
}

// Funzione principale per il recupero delle notizie (MODIFICATA)
Future<List<Notizia>> fetchNews() async {
  final String query = 'tennis NOT "calcio" NOT "basket"';
  final String lang = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  //di default magari meglio prendere quella del telefono
  //in modo smart, si potrebbe far cambiare dal menù in app bar
  final String sortby = 'publishedAt';

  // Calcola la data di una settimana fa per il filtro 'from'
  final DateTime now = DateTime.now();
  final DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));
  final String fromDate = sevenDaysAgo.toIso8601String().substring(0, 10);

  // L'API di GNews non supporta un filtro diretto per "immagine presente",
  // ma filtrando solo per 'q=tennis' si ottengono articoli pertinenti.

  final url = Uri.parse('$_baseUrl?q=$query&lang=$lang&from=$fromDate&sortby=$sortby&token=$_apiKey');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    return compute(_parseNews, response.body);
  } else {
    // TODO: Sistemare con applocalization
    throw Exception('Failed to load news. Status Code: ${response.statusCode}. Body: ${response.body}');
  }
}