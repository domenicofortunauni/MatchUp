import 'package:flutter/material.dart';
import 'package:matchup/model/TorneoModel.dart';

class TorneoCard extends StatelessWidget {
  final Torneo torneo;
  final bool isDark;

  const TorneoCard({
    super.key,
    required this.torneo,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.colorScheme.surfaceContainerHigh;
    final textColor = theme.colorScheme.inverseSurface;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      color: cardColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0)
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              torneo.nomeTorneo,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.inverseSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Dal ${torneo.dataInizio} al ${torneo.dataFine}',
                  style: theme.textTheme.titleSmall?.copyWith(color: textColor),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  '${torneo.citta} (${torneo.provincia})',
                  style: theme.textTheme.titleSmall?.copyWith(color: textColor),
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              'Organizzato da:',
              style: theme.textTheme.labelMedium?.copyWith(
                color: textColor.withValues(alpha:0.7),
              ),
            ),
            Text(
              torneo.tennisClub,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),

            // INFO EXTRA (Fonte e Iscrizione)
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                // fonte (FITP/TPRA)
                _buildInfoChip(
                  context,
                  label: torneo.idFonte,
                  icon: Icons.sports_tennis,
                  color: Theme.of(context).colorScheme.primary,
                  textColor: Colors.white,
                ),
                // Chip per l'iscrizione online
                if (torneo.iscrizioneOnline)
                  _buildInfoChip(
                    context,
                    label: 'Iscrizione Online',
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                    textColor: Colors.white,
                  )
                else
                  _buildInfoChip(
                    context,
                    label: 'Iscrizione in loco',
                    icon: Icons.cancel_outlined,
                    color: Colors.red,
                    textColor: Colors.white,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
      BuildContext context, {
        required String label,
        required IconData icon,
        required Color color,
        required Color textColor,
      }) {
    return Chip(
      avatar: Icon(icon, size: 18, color: textColor),
      label: Text(label,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
      backgroundColor: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }
}