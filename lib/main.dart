import 'package:matchup/UI/pages/Layout.dart';
import 'package:matchup/model/utils/Constants.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.AppName,
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
        primaryColor: Color(0xFF094056),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF094056),
          primary: Color(0xFF094056),
          brightness: Brightness.dark,
          surface: Colors.black
        ),
        useMaterial3: true,
      ),
      home: Layout(title: "MatchUP"),
    );
  }
}