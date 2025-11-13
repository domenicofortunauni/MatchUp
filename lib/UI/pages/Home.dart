import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import 'package:flutter/material.dart';
import 'package:matchup/UI/widgets/Prenotazione.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    List<Prenotazione>prenotazioni = [
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(15, 40, 0, 10),
            child: Text(
              "Welcome!",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: PrenotazioniWidget(prenotazioni: prenotazioni),
          ),
        ],
      ),
    );
  }
}
