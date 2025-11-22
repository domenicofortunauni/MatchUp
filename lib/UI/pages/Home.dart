import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import 'package:flutter/material.dart';
import 'package:matchup/UI/widgets/Prenotazione.dart';
import 'package:matchup/UI/widgets/Statistiche.dart';
import 'package:matchup/UI/widgets/StoricoPartite.dart';

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
        data: "24/11/2025",
        ora: "18:00",
        stato: "Confermato",
      ),
      Prenotazione(
        campo: "Campo 2 (Terra Rossa)",
        data: "24/11/2025",
        ora: "10:30",
        stato: "Confermato",
      ),
      Prenotazione(
        campo: "Campo 3 (Sintetico)",
        data: "25/11/2025",
        ora: "09:00",
        stato: "In attesa",
      ),
      Prenotazione(
        campo: "Campo Centrale",
        data: "25/11/2025",
        ora: "14:00",
        stato: "Annullato",
      ),
      Prenotazione(
        campo: "Campo Centrale",
        data: "26/11/2025",
        ora: "18:00",
        stato: "Confermato",
      ),
      Prenotazione(
        campo: "Campo 2 (Terra Rossa)",
        data: "18/11/2025",
        ora: "10:30",
        stato: "Confermato",
      ),
      Prenotazione(
        campo: "Campo 3 (Sintetico)",
        data: "19/11/2025",
        ora: "09:00",
        stato: "In attesa",
      ),
      Prenotazione(
        campo: "Campo Centrale",
        data: "15/11/2025",
        ora: "14:00",
        stato: "Annullato",
      ),Prenotazione(
        campo: "Campo Centrale",
        data: "17/11/2025",
        ora: "18:00",
        stato: "Confermato",
      ),
      Prenotazione(
        campo: "Campo 2 (Terra Rossa)",
        data: "18/11/2025",
        ora: "10:30",
        stato: "Confermato",
      ),
      Prenotazione(
        campo: "Campo 3 (Sintetico)",
        data: "19/11/2025",
        ora: "09:00",
        stato: "In attesa",
      ),
      Prenotazione(
        campo: "Campo Centrale",
        data: "15/11/2025",
        ora: "14:00",
        stato: "Annullato",
      ),
    ];

    List<Partita> storico = [
      Partita(
        avversario: "Marco Rossi",
        gameVinti: 60,
        gamePersi: 30,
        setVinti: 2,
        setPersi: 0,
        isVittoria: true,
        data: DateTime(2024, 11, 12),
      ),
      Partita(
        avversario: "Luca Bianchi",
        gameVinti: 45,
        gamePersi: 65,
        setVinti: 1,
        setPersi: 2,
        isVittoria: false,
        data: DateTime(2024, 11, 10),
      ),
      Partita(
        avversario: "Marco Rossi",
        gameVinti: 60,
        gamePersi: 30,
        setVinti: 2,
        setPersi: 0,
        isVittoria: true,
        data: DateTime(2024, 11, 12),
      ),
      Partita(
        avversario: "Luca Bianchi",
        gameVinti: 45,
        gamePersi: 65,
        setVinti: 1,
        setPersi: 2,
        isVittoria: false,
        data: DateTime(2024, 11, 10),
      ),Partita(
        avversario: "Marco Rossi",
        gameVinti: 60,
        gamePersi: 30,
        setVinti: 2,
        setPersi: 0,
        isVittoria: true,
        data: DateTime(2024, 11, 12),
      ),
      Partita(
        avversario: "Luca Bianchi",
        gameVinti: 45,
        gamePersi: 65,
        setVinti: 1,
        setPersi: 2,
        isVittoria: false,
        data: DateTime(2024, 11, 10),
      ),Partita(
        avversario: "Marco Rossi",
        gameVinti: 60,
        gamePersi: 30,
        setVinti: 2,
        setPersi: 0,
        isVittoria: true,
        data: DateTime(2024, 11, 12),
      ),
      Partita(
        avversario: "Luca Bianchi",
        gameVinti: 45,
        gamePersi: 65,
        setVinti: 1,
        setPersi: 2,
        isVittoria: false,
        data: DateTime(2024, 11, 10),
      ),Partita(
        avversario: "Marco Rossi",
        gameVinti: 60,
        gamePersi: 30,
        setVinti: 2,
        setPersi: 0,
        isVittoria: true,
        data: DateTime(2024, 11, 12),
      ),
      Partita(
        avversario: "Luca Bianchi",
        gameVinti: 45,
        gamePersi: 65,
        setVinti: 1,
        setPersi: 2,
        isVittoria: false,
        data: DateTime(2024, 11, 10),
      ),
    ];


    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(15, 40, 0, 10),
                child: Text(
                  AppLocalizations.of(context)!.translate("Welcome"),
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      PrenotazioniWidget(prenotazioni: prenotazioni),
        Statistiche(),
              StoricoPartiteWidget(partite: storico),
              const SizedBox(height: 100.0),
            ],
        ),
      ),
    );
  }
}
