import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import 'package:matchup/UI/pages/Login.dart';
import 'package:matchup/model/support/Constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'UI/pages/Login/login_page.dart';
import 'firebase_options.dart';
import 'package:matchup/services/notification_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      _themeMode = (_themeMode == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;
    });
  }
  // Metodo per aggiornare la lingua
  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    super.initState();
    NotificationService().init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: _themeMode,
      locale: _locale,
      // lingua iniziale presa dal sistema
      localeResolutionCallback: (locale, supportedLocales) {
        if (_locale != null) {
          return _locale;
        }
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first; //se non è supportata mette l'inglese
      },
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: Constants.supportedLocales,
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
      home: LoginPage(),
    );
  }
}