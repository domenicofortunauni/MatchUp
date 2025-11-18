import 'package:flutter/material.dart';
import 'package:matchup/UI/widgets/CustomSnackBar.dart';
import 'package:matchup/UI/widgets/SfideDisponibili.dart';
import 'package:matchup/UI/widgets/SfideInCorso.dart';


class Sfide extends StatefulWidget {
  const Sfide({Key? key}) : super(key: key);

  @override
  State<Sfide> createState() => _SfideState();
}

class _SfideState extends State<Sfide> {
  bool _showChallenges = false;
  int _selectedButton = -1;

  final List<SfidaModel> _sfideDisponibili = [
    SfidaModel(title: "Battaglia di Set", opponent: "Peppe"),
    SfidaModel(title: "Game Veloce", opponent: "Andrea"),
    SfidaModel(title: "Partita Singola", opponent: "Mimmo"),
    SfidaModel(title: "Sfida del Servizio", opponent: "Marco"),
  ];

  final List<SfidaModel> _sfideInCorso = [];

  Color _getButtonColor(BuildContext context, int buttonIndex) {
    if (buttonIndex == _selectedButton) {
      return Theme.of(context).colorScheme.primary;
    } else {
      return Theme.of(context).colorScheme.secondary;
    }
  }

  void _handleButtonPress(int buttonIndex) {
    setState(() {
      if (buttonIndex == _selectedButton && buttonIndex == 0) {
        _showChallenges = false;
        _selectedButton = -1;
      } else if (buttonIndex == 0) {
        _showChallenges = true;
        _selectedButton = 0;
      } else {
        _showChallenges = false;
        _selectedButton = buttonIndex;
      }
    });
  }

  void _accettaSfida(SfidaModel sfida) {
    setState(() {
      _sfideDisponibili.removeWhere((s) => s.title == sfida.title && s.opponent == sfida.opponent);
      _sfideInCorso.add(sfida);
      _showChallenges = false;
      _selectedButton = 2;
    });

    CustomSnackBar.show(context, 'Sfida contro ${sfida.opponent} accettata!');
  }

  @override
  Widget build(BuildContext context) {
    final bool showDisponibili = _showChallenges && _selectedButton == 0;
    final bool showInCorso = _selectedButton == 2 && !_showChallenges;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120.0),

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

                // Prima riga pulsanti
                Row(
                  children: [
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

                // Seconda riga pulsanti
                Row(
                  children: [
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

                // ELENCO SFIDE DISPONIBILI
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

                // ELENCO SFIDE IN CORSO
                if (showInCorso) ...[
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text(
                    "Le tue sfide accettate e in corso:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // Qui usiamo direttamente il widget.
                  // Se nel file SfideInCorso.dart hai messo il controllo per la lista vuota,
                  // non serve duplicarlo qui con if/else.
                  SfideInCorsoList(sfide: _sfideInCorso),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}