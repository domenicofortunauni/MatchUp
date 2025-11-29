import 'package:flutter/material.dart';
import 'package:matchup/UI/widgets/AggiungiPartitaStatistiche.dart';
import 'package:matchup/UI/widgets/StoricoPartite.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';

import '../../model/objects/PartitaModel.dart';

class Statistiche extends StatefulWidget {
  const Statistiche({Key? key}) : super(key: key);

  @override
  State<Statistiche> createState() => _Statistiche();
}

class _Statistiche extends State<Statistiche> {
  final List<Partita> _partiteGiocate = [];


  @override
  void initState() {
    super.initState();
    _partiteGiocate.addAll([
      Partita(
          avversario: "Mario Rossi",
          gameVinti: 60, gamePersi: 30,
          setVinti: 2, setPersi: 0,
          isVittoria: true,
          data: DateTime.now().subtract(Duration(days: 40))
      ),
      Partita(
          avversario: "Luca Bianchi",
          gameVinti: 45, gamePersi: 65,
          setVinti: 1, setPersi: 2,
          isVittoria: false,
          data: DateTime.now().subtract(Duration(days: 35))
      ),
      Partita(
          avversario: "Marco Verdi",
          gameVinti: 70, gamePersi: 50,
          setVinti: 2, setPersi: 1,
          isVittoria: true,
          data: DateTime.now().subtract(Duration(days: 10))
      ),
      Partita(
          avversario: "Andrea Gialli",
          gameVinti: 20, gamePersi: 60,
          setVinti: 0, setPersi: 2,
          isVittoria: false,
          data: DateTime.now().subtract(Duration(days: 5))
      ),
    ]);
  }

  void aggiungiNuovaPartita(Partita nuovaPartita) {
    setState(() {
      _partiteGiocate.add(nuovaPartita);
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dataLimite = now.subtract(Duration(days: 30));

    int totalePartite = _partiteGiocate.length;
    int totaleGameVinti = 0;
    int totaleGamePersi = 0;
    int totaleVittorie = 0;

    int totalePartiteUltimi30Giorni = 0;
    int totaleVittorieUltimi30Giorni = 0;

    for (var partita in _partiteGiocate) {
      totaleGameVinti += partita.gameVinti;
      totaleGamePersi += partita.gamePersi;
      if (partita.isVittoria) {
        totaleVittorie++;
      }

      if (partita.data.isAfter(dataLimite)) {
        totalePartiteUltimi30Giorni++;
        if (partita.isVittoria) {
          totaleVittorieUltimi30Giorni++;
        }
      }
    }

    double percentualeVittorieTotale = (totalePartite == 0)
        ? 0
        : (totaleVittorie / totalePartite) * 100;

    double percentualeVittorieUltimi30Giorni = (totalePartiteUltimi30Giorni == 0)
        ? 0
        : (totaleVittorieUltimi30Giorni / totalePartiteUltimi30Giorni) * 100;

    return Card(
      elevation: 4.0,
      margin: EdgeInsets.all(12.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.translate("Statistiche Partite"),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.translate("Partite Giocate:") + " $totalePartite",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.translate("Game Totali Vinti:") + " $totaleGameVinti",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.translate("Game Totali Persi:") + " $totaleGamePersi",
              style: TextStyle(fontSize: 18),
            ),
            Divider(height: 24),
            Text(
              AppLocalizations.of(context)!.translate("Vittorie Totali:") +
                  " $totaleVittorie " +
                  AppLocalizations.of(context)!.translate("su") +
                  " $totalePartite " +
                  AppLocalizations.of(context)!.translate("partite"),
              style: TextStyle(fontSize: 18),
            ),
            Text(
              AppLocalizations.of(context)!.translate("Percentuale Vittorie (Totale):") +
                  " ${percentualeVittorieTotale.toStringAsFixed(1)}%",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[700]),
            ),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.translate("Vittorie (Ultimi 30gg):") +
                  " $totaleVittorieUltimi30Giorni " +
                  AppLocalizations.of(context)!.translate("su") +
                  " $totalePartiteUltimi30Giorni " +
                  AppLocalizations.of(context)!.translate("partite"),
              style: TextStyle(fontSize: 18),
            ),
            Text(
              AppLocalizations.of(context)!.translate("Percentuale Vittorie (Ultimi 30gg):") +
                  " ${percentualeVittorieUltimi30Giorni.toStringAsFixed(1)}%",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple[700]),
            ),

            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
              child: Text(AppLocalizations.of(context)!.translate("Aggiungi Nuova Partita"), style: TextStyle(fontSize: 16, color: Colors.white)),
              onPressed: () async {
                final nuovaPartita = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AggiungiPartitaStatistiche()),
                );
                if (nuovaPartita != null && nuovaPartita is Partita) {
                  aggiungiNuovaPartita(nuovaPartita);
                }
              },
            )
          ],
        ),
      ),
    );
  }
}