import 'package:flutter/material.dart';
import '../../../model/objects/StatisticheModel.dart';
import '../../behaviors/AppLocalizations.dart';

class StatisticheCard extends StatelessWidget {
  final StatisticheModel stats;
  const StatisticheCard({Key? key, required this.stats,}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary.withValues(alpha: 0.1), Theme.of(context).colorScheme.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //PARTITE GIOCATE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.translate("Partite giocate:"),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text( "${stats.totalePartite}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Game Vinti / Persi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Game Vinti
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.translate("Game totali vinti:"),
                      style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                  Text("${stats.totaleGameVinti}",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              // Game Persi
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(AppLocalizations.of(context)!.translate("Game totali persi:"),
                      style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
                  Text("${stats.totaleGamePersi}",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Barra progresso game
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: stats.percGameVinti,
              minHeight: 10,
              backgroundColor: stats.percGameVinti==0 ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.8),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),

          const SizedBox(height: 20),
          Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          const SizedBox(height: 10),

          // Vittorie totali
          _buildStatRow(
            context,
            label: AppLocalizations.of(context)!.translate("Vittorie totali:"),
            percentage: stats.percVittorieTotali,
            detail: "${AppLocalizations.of(context)!.translate("su")} ${stats.totalePartite} ${AppLocalizations.of(context)!.translate("partite")}",
            valueCount: stats.totaleVittorie,
            color: Theme.of(context).colorScheme.primary,
          ),

          const SizedBox(height: 16),

          // Vittorie 30 GG
          _buildStatRow(
            context,
            label: AppLocalizations.of(context)!.translate("Vittorie (ultimi 30gg):"),
            percentage: stats.percVittorieUltimi30,
            detail: "${AppLocalizations.of(context)!.translate("su")} ${stats.partiteUltimi30} ${AppLocalizations.of(context)!.translate("partite")}",
            valueCount: stats.vittorieUltimi30,
            color: Colors.purple[700]!,
          ),
        ],
      ),
    );
  }
  Widget _buildStatRow(BuildContext context, {
    required String label,
    required double percentage,
    required String detail,
    required int valueCount,
    required Color color
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Cerchio Percentuale
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 50, height: 50,
              child: CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 5,
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(
              "${percentage.toStringAsFixed(0)}%",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),),
          ],
        ),
        const SizedBox(width: 16),
        // Testi
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
              RichText(
                text: TextSpan(style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14),
                  children: [
                    TextSpan(
                        text: "$valueCount ",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                    TextSpan(text: detail),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}