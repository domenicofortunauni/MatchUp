import 'package:flutter/material.dart';
import 'package:matchup/UI/widgets/home/Prenotazioni.dart';
import 'package:matchup/UI/widgets/home/Statistiche.dart';
import 'package:matchup/UI/widgets/home/StoricoPartite.dart';

class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: ListView(
        children: const[
            const PrenotazioniWidget(),
            const Statistiche(),
            const StoricoPartiteWidget(),
          ],
        ),
      );
  }
}