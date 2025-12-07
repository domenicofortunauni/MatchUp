import 'package:flutter/material.dart';
import '../../behaviors/AppLocalizations.dart';

class noPartiteStorico extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.sports_tennis_outlined, size: 50, color: Colors.grey.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.translate("Nessuna partita nello storico"),
                style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
      );
    }
}