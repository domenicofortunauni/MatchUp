import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import 'package:flutter/material.dart';
import 'package:matchup/UI/widgets/Prenotazione.dart';
import 'package:matchup/UI/widgets/Statistiche.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    // Esempio di prenotazioni
    List<Prenotazione> prenotazioni = [
      Prenotazione(
        campo: "Campo Centrale",
        data: "17 Novembre",
        ora: "18:00",
        stato: "Confermato",
      ),
      Prenotazione(
        campo: "Campo 2 (Terra Rossa)",
        data: "18 Novembre",
        ora: "10:30",
        stato: "Confermato",
      ),
      Prenotazione(
        campo: "Campo 3 (Sintetico)",
        data: "19 Novembre",
        ora: "09:00",
        stato: "In attesa",
      ),
      Prenotazione(
        campo: "Campo Centrale",
        data: "15 Novembre",
        ora: "14:00",
        stato: "Annullato",
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
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

      PrenotazioniWidget(prenotazioni: prenotazioni),
        Statistiche(),
              const SizedBox(height: 100.0),
            ],
        ),
      ),
    );
  }
}
