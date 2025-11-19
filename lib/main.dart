import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import 'package:matchup/UI/pages/Login.dart';
import 'package:matchup/model/utils/Constants.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => MyAppState();

  // Metodo statico per accedere allo stato da widget figli
  static MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>();

}
class MyAppState extends State<MyApp> {
  // Variabile di stato per contenere la lingua corrente
  Locale? _locale;

  // Getter per accedere alla lingua corrente in altri widget
  Locale get currentLocale => _locale ?? WidgetsBinding.instance.platformDispatcher.locale;

  ThemeMode _themeMode = ThemeMode.system; // tema del sistema
  // Funzione per cambiare tema
  void toggleTheme() {
    setState(() {
      _themeMode =
      _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }
  // Metodo per aggiornare la lingua
  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.AppName,
      themeMode: _themeMode,
      locale: _locale,
      // Qui lingua iniziale presa dal sistema
      localeResolutionCallback: (locale, supportedLocales) {
        if (_locale != null) {
          return _locale;
        }
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('it'),
        Locale('fr'), // Aggiungere altre lingue
      ],
      theme: ThemeData(
        primaryColor: Color(0xFF3E963D),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF3E963D),
          primary: Color(0xFF3E963D),
          brightness: Brightness.light,
          surface: Colors.white
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        primaryColor: Colors.blue[900],
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue[900]!,
          primary: Colors.blue[900],
          brightness: Brightness.dark,
          surface: Colors.black
        ),
        useMaterial3: true,
      ),
      home: Login(),
    );
  }
}