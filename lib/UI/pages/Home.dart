import 'package:flutter/material.dart';
import 'package:matchup/UI/widgets/home/Prenotazioni.dart'; // Assicurati che il nome del file corrisponda
import 'package:matchup/UI/widgets/home/Statistiche.dart';
import 'package:matchup/UI/widgets/home/StoricoPartite.dart';
// Non serve più importare PartitaModel qui se non lo usi per altro
// import '../../model/objects/PartitaModel.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    // ABBIAMO RIMOSSO LA LISTA STATICA 'storico' PERCHÉ ORA I DATI ARRIVANO DA FIREBASE

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Assicurati che PrenotazioniWidget sia definito e importato correttamente
            // Se il file si chiama prenotazioni_widget.dart, aggiorna l'import sopra.
            const PrenotazioniWidget(),

            const Statistiche(), // Aggiunto const per ottimizzazione

            // CORREZIONE QUI: Rimosso il parametro (partite: storico)
            const StoricoPartiteWidget(),

            const SizedBox(height: 100.0),
          ],
        ),
      ),
    );
  }
}