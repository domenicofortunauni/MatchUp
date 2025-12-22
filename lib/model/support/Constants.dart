import 'dart:ui';

import 'package:flutter/material.dart';

class Constants{
  static final String APIKEY_METEO = '5535814125ef257bfbf9eb262e4c66ba ';
  static final String API_METEO_URL = 'https://api.openweathermap.org/data/2.5/forecast';
  static final String AppName = "MatchUP";
  static final Color matchCardColorDark = Color(0xFF2C2C2C);
  static final Color matchCardColorLight = Colors.white;
  static const String API_TORNEI_URL = 'https://appflutter-5frv.vercel.app/api/proxy';
  static const String APIKEY_GNEWS = '470ca9d053c288330bf2c04403b58850';
  static const String API_GNEWS_URL = 'https://gnews.io/api/v4/search';
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('it'),
    Locale('fr'),
    Locale('es'),
    Locale('de'),
  ];
  static const livelliKeys = [
    "Amatoriale",
    "Dilettante",
    "Intermedio",
    "Avanzato",
    "Professionista",
  ];
}
