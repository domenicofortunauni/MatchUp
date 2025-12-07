import 'package:flutter/material.dart';
import '../../behaviors/AppLocalizations.dart';

class noPrenotazioni extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.event_busy_rounded, size: 40,
                  color: Colors.grey.shade400),
            ),
            const SizedBox(height: 5),
            Text(
              AppLocalizations.of(context)!.translate("Nessuna prenotazione"),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600),
            ),
            Text(
              AppLocalizations.of(context)!.translate("Non hai partite in programma per oggi"),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}