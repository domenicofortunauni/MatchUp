import 'package:flutter/material.dart';
import 'package:matchup/model/objects/TorneoModel.dart';
import '../../behaviors/AppLocalizations.dart';

class TorneoCard extends StatelessWidget {
  final Torneo torneo;

  const TorneoCard({
    super.key,
    required this.torneo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.inverseSurface;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
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
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.translate("Dal") +
                      " ${torneo.dataInizio}" +
                      AppLocalizations.of(context)!.translate(" al ") +
                      "${torneo.dataFine}",
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
              AppLocalizations.of(context)!.translate("Organizzato da:"),
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

            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                // fonte (FITP/TPRA)
                _buildInfoChip(
                  context,
                  label: torneo.idFonte,
                  icon: Icons.sports_tennis,
                  color: Colors.blue[900]!,
                  textColor: Colors.white,
                ),
                if (torneo.iscrizioneOnline)
                  _buildInfoChip(
                    context,
                    label: AppLocalizations.of(context)!.translate("Iscrizione Online"),
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                    textColor: Colors.white,
                  )
                else
                  _buildInfoChip(
                    context,
                    label: AppLocalizations.of(context)!.translate("Iscrizione in loco"),
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