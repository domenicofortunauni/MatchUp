import 'package:flutter/material.dart';
import 'package:matchup/UI/widgets/CustomSnackBar.dart';
import 'package:matchup/UI/widgets/SfideDisponibili.dart';
import 'package:matchup/UI/widgets/SfideInCorso.dart';
import 'package:matchup/UI/widgets/SfideInviate.dart';
import 'package:matchup/UI/widgets/SfideRicevute.dart';
import 'package:matchup/UI/widgets/CreaSfida.dart';

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
  List<SfidaModel> _sfideInviateList = [];

  List<SfidaModel> _sfideRicevuteList = [
    SfidaModel(title: "Rivincita", opponent: "Giovanni"),
    SfidaModel(title: "Tie Break", opponent: "Luca"),
  ];

  Color _getButtonColor(BuildContext context, int buttonIndex) {
    return (buttonIndex == _selectedButton)
        ? Theme.of(context).colorScheme.primary
        : Colors.grey.shade700;
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

  // NUOVA LOGICA PER RICEVUTE
  void _accettaRicevuta(SfidaModel sfida) {
    setState(() {
      _sfideRicevuteList = List.from(_sfideRicevuteList)..remove(sfida);
      _sfideInCorso.add(sfida);
      _selectedButton = 2; // Sposta la vista su In Corso
      _showChallenges = false;
    });
    CustomSnackBar.show(context, 'Sfida di ${sfida.opponent} accettata!');
  }

  void _rifiutaRicevuta(SfidaModel sfida) {
    setState(() {
      _sfideRicevuteList = List.from(_sfideRicevuteList)..remove(sfida);
    });
    CustomSnackBar.show(context, 'Sfida di ${sfida.opponent} rifiutata.');
  }

  Future<void> _navigaEcreaSfida() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreaSfida()),
    );

    if (result != null) {
      try {
        final nuovaSfida = result as SfidaModel;
        setState(() {
          _sfideInviateList = [..._sfideInviateList, nuovaSfida];
          _selectedButton = 1;
          _showChallenges = false;
        });
        CustomSnackBar.show(context, 'Sfida inviata a ${nuovaSfida.opponent}!');
      } catch (e) {
        print("Errore nel recupero della sfida creata: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showDisponibili = _showChallenges && _selectedButton == 0;
    final bool showInviate = _selectedButton == 1 && !_showChallenges;
    final bool showInCorso = _selectedButton == 2 && !_showChallenges;
    final bool showRicevute = _selectedButton == 3 && !_showChallenges; // Logica per Ricevute

    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0, right: 5.0),
        child: FloatingActionButton(
          onPressed: _navigaEcreaSfida,
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 4,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),

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

                // Bottoni Riga 1
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
                        child: const Text('Inviate', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Bottoni Riga 2
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

                if (showInviate) ...[
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text(
                    "Sfide che hai inviato:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SfideInviateSection(
                    sfideInviate: _sfideInviateList,
                  ),
                ],

                if (showInCorso) ...[
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text(
                    "Le tue sfide accettate e in corso:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SfideInCorsoList(sfide: _sfideInCorso),
                ],

                if (showRicevute) ...[
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text(
                    "Sfide ricevute da altri giocatori:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SfideRicevuteSection(
                    sfide: _sfideRicevuteList,
                    onAccetta: _accettaRicevuta,
                    onRifiuta: _rifiutaRicevuta,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}