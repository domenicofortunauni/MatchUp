import 'package:flutter/material.dart';
import 'package:matchup/UI/widgets/sfide/SfideDisponibili.dart';
import 'package:matchup/UI/widgets/sfide/SfideInCorso.dart';
import 'package:matchup/UI/widgets/sfide/SfideInviate.dart';
import 'package:matchup/UI/widgets/sfide/SfideRicevute.dart';
import 'package:matchup/UI/widgets/sfide/CreaSfida.dart';
import '../widgets/buttons/CircularFloatingIconButton.dart';

class Sfide extends StatefulWidget {
  const Sfide({Key? key}) : super(key: key);

  @override
  State<Sfide> createState() => _SfideState();
}

class _SfideState extends State<Sfide> {
  // 0 = Disponibili (Pubbliche)
  // 1 = Inviate (Create da me in attesa)
  // 2 = In Corso (Accettate)
  // 3 = Ricevute (Inviti diretti per me)
  // -1 = Nessuno selezionato (o default)
  int _selectedButton = 0; // Default mostriamo le disponibili

  Color _getButtonColor(BuildContext context, int buttonIndex) {
    return (buttonIndex == _selectedButton)
        ? Theme.of(context).colorScheme.primary
        : Colors.grey.shade700;
  }

  void _handleButtonPress(int buttonIndex) {
    setState(() {
      _selectedButton = buttonIndex;
    });
  }

  Future<void> _navigaEcreaSfida() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreaSfida()),
    );

    // Al ritorno, potremmo mostrare le "inviate"
    setState(() {
      _selectedButton = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: CircularFloatingIconButton(
        onPressed: _navigaEcreaSfida,
        icon: Icons.add,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120.0),
        child: Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surface,
          margin: const EdgeInsets.all(12.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Le tue sfide',
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

                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 10),

                if (_selectedButton == 0) ...[
                  const Text(
                    "Sfide pubbliche disponibili:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const SfideDisponibiliList(),
                ] else if (_selectedButton == 1) ...[
                  const Text(
                    "Sfide che hai inviato:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const SfideInviateSection(),
                ] else if (_selectedButton == 2) ...[
                  const Text(
                    "Partite accettate e in corso:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const SfideInCorsoList(),
                ] else if (_selectedButton == 3) ...[
                  const Text(
                    "Sfide ricevute da altri giocatori:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const SfideRicevuteSection(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}