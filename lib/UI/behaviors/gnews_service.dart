import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

// Chiave API (è bene tenerla fuori dal codice sorgente in produzione, ma per l'esempio va qui)
const String _apiKey = '470ca9d053c288330bf2c04403b58850';
const String _baseUrl = 'https://gnews.io/api/v4/search';

// Modello dei Dati per un Articolo
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

  // Factory per creare un oggetto Notizia dal JSON
  factory Notizia.fromJson(Map<String, dynamic> json) {
    return Notizia(
      titolo: json['title'] ?? 'Nessun Titolo',
      descrizione: json['description'] ?? 'Nessuna descrizione disponibile.',
      // GNews usa 'image' per l'URL dell'immagine
      urlImmagine: json['image'] ?? 'https://via.placeholder.com/150',
      fonte: json['source']?['name'] ?? 'Sconosciuta',
      urlArticolo: json['url'] ?? '',
    );
  }
}

// Funzione di Parsing Eseguita in Isolate (per ottimizzare le performance)
// Come discusso, questa funzione viene eseguita su un thread separato (Isolate)
List<Notizia> _parseNews(String responseBody) {
  final Map<String, dynamic> data = json.decode(responseBody);
  final List<dynamic> articlesJson = data['articles'] ?? [];

  return articlesJson.map((json) => Notizia.fromJson(json)).toList();
}

// Funzione principale per il recupero delle notizie
Future<List<Notizia>> fetchNews() async {
  // Filtri richiesti: "sport tennis" e news degli ultimi giorni (settimana)
  final String query = 'sport AND tennis';
  final String lang = 'it'; // Lingua Italiana
  final String sortby = 'publishedAt'; // Ordina per data di pubblicazione

  // Calcola la data di una settimana fa per il filtro 'from'
  final DateTime now = DateTime.now();
  final DateTime oneWeekAgo = now.subtract(const Duration(days: 7));
  final String fromDate = oneWeekAgo.toIso8601String().substring(0, 10); // Formato YYYY-MM-DD

  final url = Uri.parse('$_baseUrl?q=$query&lang=$lang&from=$fromDate&sortby=$sortby&token=$_apiKey');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    // Utilizza compute per eseguire il parsing del JSON in un Isolate separato
    return compute(_parseNews, response.body);
  } else {
    // Gestione degli errori API (es. limite di chiamate, chiave non valida)
    throw Exception('Failed to load news. Status Code: ${response.statusCode}. Body: ${response.body}');
  }
}