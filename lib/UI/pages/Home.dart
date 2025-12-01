import 'package:flutter/material.dart';
import 'package:matchup/UI/widgets/home/Prenotazioni.dart';
import 'package:matchup/UI/widgets/home/Statistiche.dart';
import 'package:matchup/UI/widgets/home/StoricoPartite.dart';
import '../../model/objects/PartitaModel.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {

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
    ];


    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PrenotazioniWidget(),
              Statistiche(),
              StoricoPartiteWidget(partite: storico),
              const SizedBox(height: 100.0),
            ],
        ),
      ),
    );
  }
}
