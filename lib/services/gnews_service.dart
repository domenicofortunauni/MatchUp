import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../model/objects/NotiziaModel.dart';
import '../model/support/Constants.dart';


List<Notizia> _parseNews(String responseBody) {
  final Map<String, dynamic> data = json.decode(responseBody);
  final List<dynamic> articlesJson = data['articles'] ?? [];

  return articlesJson
      .map((json) => Notizia.fromJson(json))
      .toList();
}

// Funzione per il recupero delle notizie
Future<List<Notizia>> fetchNews(String languageCode) async {
  String baseQuery = 'tennis';
  String context = '(ATP OR WTA OR "Davis Cup" OR "Grand Slam" OR Wimbledon OR "Roland Garros" OR "US Open" OR "Australian Open")';
  String exclusions = 'NOT "table tennis" NOT "ping pong" NOT padel NOT audience NOT ascolti NOT tv';
  final String query = '$baseQuery AND $context $exclusions';
  final String lang = languageCode; //passata dalla lingua corrente
  final String sortby = 'publishedAt';

  final DateTime now = DateTime.now();
  final DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));
  final String fromDate = sevenDaysAgo.toIso8601String().substring(0, 10);

  final url = Uri.parse('${Constants.API_GNEWS_URL}?q=$query&lang=$lang&from=$fromDate&sortby=$sortby&token=${Constants.APIKEY_GNEWS}');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    return compute(_parseNews, response.body);
  } else {
    return [];
  }
}