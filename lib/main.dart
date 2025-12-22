import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';
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
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => MyAppState();

  // Metodo statico per accedere allo stato da widget figli
  static MyAppState of(BuildContext context) => context.findAncestorStateOfType<MyAppState>()!;
}
class MyAppState extends State<MyApp> {
  Locale? _locale;
  ThemeMode _themeMode = ThemeMode.system;
  // metodo per cambiare tema
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
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: _themeMode,
      locale: _locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate],
      supportedLocales: Constants.supportedLocales,
      title: 'MatchUP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3E963D),
          primary: const Color(0xFF3E963D),
          brightness: Brightness.light,
          surface: Colors.white
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor:  Colors.blue[900]!,
          primary:  Colors.blue[900],
          brightness: Brightness.dark,
          surface: Colors.black,
        ),
        useMaterial3: true,
      ),
      home: LoginPage(),
    );
  }
}