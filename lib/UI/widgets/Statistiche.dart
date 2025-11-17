import 'package:flutter/material.dart';
import 'package:matchup/UI/pages/AggiungiPartitaStatistiche.dart';

class Partita {
  final int puntiFatti;
  final int puntiSubiti;
  final int setVinti;
  final int setPersi;
  final bool isVittoria;
  final DateTime data;

  Partita({
    required this.puntiFatti,
    required this.puntiSubiti,
    required this.setVinti,
    required this.setPersi,
    required this.isVittoria,
    required this.data,
  });
}

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
      // Esempi di partite
      Partita(
          puntiFatti: 60, puntiSubiti: 30,
          setVinti: 2, setPersi: 0,
          isVittoria: true,
          data: DateTime.now().subtract(Duration(days: 40))
      ),
      Partita(
          puntiFatti: 45, puntiSubiti: 65,
          setVinti: 1, setPersi: 2,
          isVittoria: false,
          data: DateTime.now().subtract(Duration(days: 35))
      ),
      Partita(
          puntiFatti: 70, puntiSubiti: 50,
          setVinti: 2, setPersi: 1,
          isVittoria: true,
          data: DateTime.now().subtract(Duration(days: 10))
      ),
      Partita(
          puntiFatti: 20, puntiSubiti: 60,
          setVinti: 0, setPersi: 2,
          isVittoria: false,
          data: DateTime.now().subtract(Duration(days: 5))
      ),
    ]);
  }

  // Metodo per aggiungere una nuova partita
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
    int totalePuntiFatti = 0;
    int totalePuntiSubiti = 0;
    int totaleVittorie = 0;

    // Statistiche per gli ultimi 30 giorni
    int totalePartiteUltimi30Giorni = 0;
    int totaleVittorieUltimi30Giorni = 0;

    for (var partita in _partiteGiocate) {
      // Calcoli totali
      totalePuntiFatti += partita.puntiFatti;
      totalePuntiSubiti += partita.puntiSubiti;
      if (partita.isVittoria) {
        totaleVittorie++;
      }

      // Calcoli per gli ultimi 30 giorni
      // Controlla se la data della partita è dopo la data limite
      if (partita.data.isAfter(dataLimite)) {
        totalePartiteUltimi30Giorni++;
        if (partita.isVittoria) {
          totaleVittorieUltimi30Giorni++;
        }
      }
    }

    // Calcolo percentuali
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
            Text(
              'Statistiche Partite',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            Text(
              'Partite Giocate: $totalePartite',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Punti Totali Fatti: $totalePuntiFatti',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Punti Totali Subiti: $totalePuntiSubiti',
              style: TextStyle(fontSize: 18),
            ),
            Divider(height: 24),
            Text(
              'Vittorie Totali: $totaleVittorie su $totalePartite partite',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Percentuale Vittorie (Totale): ${percentualeVittorieTotale.toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[700]),
            ),
            SizedBox(height: 16),
            Text(
              'Vittorie (Ultimi 30gg): $totaleVittorieUltimi30Giorni su $totalePartiteUltimi30Giorni partite',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Percentuale Vittorie (Ultimi 30gg): ${percentualeVittorieUltimi30Giorni.toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple[700]),
            ),

            // Pulsante per aggiungere una nuova partita
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Aggiungi Nuova Partita'),
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