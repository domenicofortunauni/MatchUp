import 'package:flutter/material.dart';
import 'package:matchup/UI/widgets/SfideDisponibili.dart';
import 'package:matchup/UI/widgets/SfideInCorso.dart';

class Sfide extends StatefulWidget {
  const Sfide({Key? key}) : super(key: key);

  @override
  State<Sfide> createState() => _SfideState();
}

class _SfideState extends State<Sfide> {
  // Variabile di stato per mostrare/nascondere l'elenco delle sfide disponibili
  bool _showChallenges = false;

  // Variabile di stato per tracciare il pulsante selezionato (-1: nessuno, 0, 1, 2, 3)
  int _selectedButton = -1;

  final List<SfidaModel> _sfideDisponibili = [
    SfidaModel(title: "Battaglia di Set", opponent: "Peppe"),
    SfidaModel(title: "Game Veloce", opponent: "Andrea"),
    SfidaModel(title: "Partita Singola", opponent: "Mimmo"),
    SfidaModel(title: "Sfida del Servizio", opponent: "Marco"),
  ];

  // Lista per le sfide accettate (Sfide in Corso)
  final List<SfidaModel> _sfideInCorso = [];


  // Funzione helper per determinare il colore del pulsante
  Color _getButtonColor(BuildContext context, int buttonIndex) {
    if (buttonIndex == _selectedButton) {
      return Theme.of(context).colorScheme.primary;
    } else {
      return Theme.of(context).colorScheme.secondary;
    }
  }

  //Gestisce la selezione e la visibilità della lista
  void _handleButtonPress(int buttonIndex) {
    setState(() {
      if (buttonIndex == _selectedButton && buttonIndex == 0) {
        // Caso 1: Click sul bottone 0 già selezionato (lo chiude)
        _showChallenges = false;
        _selectedButton = -1;
      } else if (buttonIndex == 0) {
        // Caso 2: Click sul bottone 0 (lo apre e lo seleziona)
        _showChallenges = true;
        _selectedButton = 0;
      } else {
        // Caso 3: Click su qualsiasi altro bottone (lo seleziona e nasconde la lista)
        _showChallenges = false;
        _selectedButton = buttonIndex;
      }
    });
  }

  // Funzione per accettare una sfida (passata al widget figlio)
  void _accettaSfida(SfidaModel sfida) {
    setState(() {
      // 1. Rimuovi la sfida dalla lista delle Disponibili
      _sfideDisponibili.removeWhere((s) => s.title == sfida.title && s.opponent == sfida.opponent);

      // 2. Aggiungi la sfida alla lista in Corso
      _sfideInCorso.add(sfida);

      // 3. Sposta la visualizzazione a "Sfide in Corso"
      _showChallenges = false;
      _selectedButton = 2; // Indice 2 = Sfide in Corso
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sfida accettata! Partita contro ${sfida.opponent} aggiunta alle Sfide in Corso.')),
    );
  }


  @override
  Widget build(BuildContext context) {
    // VARIABILI PER LA VISUALIZZAZIONE CONDIZIONALE
    final bool showDisponibili = _showChallenges && _selectedButton == 0;
    final bool showInCorso = _selectedButton == 2 && !_showChallenges;

    return Scaffold(
      body: SingleChildScrollView(
        child: Card(
          elevation: 4.0,
          margin: const EdgeInsets.all(12.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Container Titolo
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Le Tue Sfide',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Prima riga di pulsanti
                Row(
                  children: [
                    // Bottone 0: Sfide Disponibili
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleButtonPress(0),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getButtonColor(context, 0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Disponibili', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Bottone 1: Crea/Inviate
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleButtonPress(1),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getButtonColor(context, 1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Crea/Inviate', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Seconda riga di pulsanti
                Row(
                  children: [
                    // Bottone 2: Sfide in Corso
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleButtonPress(2),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getButtonColor(context, 2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('In Corso', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Bottone 3: Sfide Ricevute (Reintrodotto)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleButtonPress(3),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getButtonColor(context, 3),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Ricevute', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),

                // ELENCO DELLE SFIDE DISPONIBILI (Mostrato solo quando 0 è selezionato)
                if (showDisponibili) ...[
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text(
                    "Sfide in attesa di accettazione:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SfideDisponibiliList(
                    sfide: _sfideDisponibili,
                    onAccetta: _accettaSfida,
                  ),
                ],

                // ELENCO DELLE SFIDE IN CORSO (Mostrato solo quando 2 è selezionato)
                if (showInCorso) ...[
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text(
                    "Le tue sfide accettate e in corso:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (_sfideInCorso.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("Nessuna sfida in corso."),
                    )
                  else
                  // Elenco delle sfide in corso
                    SfideInCorsoList(sfide: _sfideInCorso),
                ]
                // ------------------------------------------------------------------------
              ],
            ),
          ),
        ),
      ),
    );
  }
}