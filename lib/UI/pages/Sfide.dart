import 'package:flutter/material.dart';
import 'package:matchup/UI/widgets/sfide/SfideDisponibili.dart';
import 'package:matchup/UI/widgets/sfide/SfideInCorso.dart';
import 'package:matchup/UI/widgets/sfide/SfideInviate.dart';
import 'package:matchup/UI/widgets/sfide/SfideRicevute.dart';
import '../behaviors/AppLocalizations.dart';
import '../widgets/buttons/CircularFloatingIconButton.dart';
import '../widgets/buttons/Sfida_button.dart';
import '../widgets/popup/ListaCampi.dart';

class Sfide extends StatefulWidget {
  const Sfide({Key? key}) : super(key: key);
  @override
  State<Sfide> createState() => _SfideState();
}

class _SfideState extends State<Sfide> {
  // 0 = Disponibili, 1 = Inviate, 2 = In Corso, 3 = Ricevute
  int _selectedButton = 0;

  void _handleButtonPress(int buttonIndex) {
    setState(() {
      _selectedButton = buttonIndex;
    });
  }

//apertura popup per organizzare una sfida
  void _apriListaCampi(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ListaCampiPopup(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: CircularFloatingIconButton(
        onPressed: () => _apriListaCampi(context),
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
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.translate('Le tue sfide'),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // Bottoni Riga 1
                Row(
                  children: [
                    Expanded(
                        child: Sfida_button(
                          label: 'Disponibili',
                          selected: _selectedButton == 0,
                          onPressed: () => _handleButtonPress(0),
                        ),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                        child: Sfida_button(
                          label: 'Inviate',
                          selected: _selectedButton == 1,
                          onPressed: () => _handleButtonPress(1),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 15),
                // Bottoni Riga 2
                Row(
                  children: [
                    Expanded(
                      child: Sfida_button(
                        label: 'In Corso',
                        selected: _selectedButton == 2,
                        onPressed: () => _handleButtonPress(2),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Sfida_button(
                        label: 'Ricevute',
                        selected: _selectedButton == 3,
                        onPressed: () => _handleButtonPress(3),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 10),

                // Contenuto Dinamico
                if (_selectedButton == 0) ...[
                  Text(AppLocalizations.of(context)!.translate("Sfide pubbliche disponibili:"), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  const SfideDisponibiliList(),
                ] else if (_selectedButton == 1) ...[
                  Text(AppLocalizations.of(context)!.translate("Sfide che hai inviato:"), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  const SfideInviateList(),
                ] else if (_selectedButton == 2) ...[
                  Text(AppLocalizations.of(context)!.translate("Partite accettate e in corso:"), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  const SfideInCorsoList(),
                ] else if (_selectedButton == 3) ...[
                  Text(AppLocalizations.of(context)!.translate("Sfide ricevute da altri giocatori:"), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  const SfideRicevuteList(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}