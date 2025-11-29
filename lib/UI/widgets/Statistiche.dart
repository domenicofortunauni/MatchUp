import 'package:flutter/material.dart';
import 'package:matchup/UI/widgets/AggiungiPartitaStatistiche.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import '../../model/objects/PartitaModel.dart';

class Statistiche extends StatefulWidget {
  const Statistiche({Key? key}) : super(key: key);

  @override
  State<Statistiche> createState() => _StatisticheState();
}

class _StatisticheState extends State<Statistiche> {
  final List<Partita> _partiteGiocate = [];

  @override
  void initState() {
    super.initState();
    // Dati di prova
    _partiteGiocate.addAll([
      Partita(avversario: "Mario Rossi", gameVinti: 60, gamePersi: 30, setVinti: 2, setPersi: 0, isVittoria: true, data: DateTime.now().subtract(const Duration(days: 40))),
      Partita(avversario: "Luca Bianchi", gameVinti: 45, gamePersi: 65, setVinti: 1, setPersi: 2, isVittoria: false, data: DateTime.now().subtract(const Duration(days: 35))),
      Partita(avversario: "Marco Verdi", gameVinti: 70, gamePersi: 50, setVinti: 2, setPersi: 1, isVittoria: true, data: DateTime.now().subtract(const Duration(days: 10))),
      Partita(avversario: "Andrea Gialli", gameVinti: 20, gamePersi: 60, setVinti: 0, setPersi: 2, isVittoria: false, data: DateTime.now().subtract(const Duration(days: 5))),
    ]);
  }

  void aggiungiNuovaPartita(Partita nuovaPartita) {
    setState(() {
      _partiteGiocate.add(nuovaPartita);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = AppLocalizations.of(context)!;

    // Calcoli
    final now = DateTime.now();
    final dataLimite = now.subtract(const Duration(days: 30));

    int totalePartite = _partiteGiocate.length;
    int totaleGameVinti = 0;
    int totaleGamePersi = 0;
    int totaleVittorie = 0;

    int totalePartiteUltimi30Giorni = 0;
    int totaleVittorieUltimi30Giorni = 0;

    for (var partita in _partiteGiocate) {
      totaleGameVinti += partita.gameVinti;
      totaleGamePersi += partita.gamePersi;
      if (partita.isVittoria) {
        totaleVittorie++;
      }

      if (partita.data.isAfter(dataLimite)) {
        totalePartiteUltimi30Giorni++;
        if (partita.isVittoria) {
          totaleVittorieUltimi30Giorni++;
        }
      }
    }

    double percentualeVittorieTotale = (totalePartite == 0)
        ? 0
        : (totaleVittorie / totalePartite) * 100;

    double percentualeVittorieUltimi30Giorni = (totalePartiteUltimi30Giorni == 0)
        ? 0
        : (totaleVittorieUltimi30Giorni / totalePartiteUltimi30Giorni) * 100;

    int totaleGame = totaleGameVinti + totaleGamePersi;
    double percGameVintiBarra = (totaleGame == 0) ? 0 : (totaleGameVinti / totaleGame);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITOLO
          Text(
            AppLocalizations.of(context)!.translate("Le tue statistiche"),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary.withValues(alpha:0.1), Theme.of(context).colorScheme.surface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colorScheme.primary.withValues(alpha:0.2)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // 1. PARTITE GIOCATE (HEADER)
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
                      child: Text(
                        "$totalePartite",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Sezione game
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Game Vinti
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.translate("Game totali vinti:"), style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                        Text("$totaleGameVinti", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    // Game Persi
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(AppLocalizations.of(context)!.translate("Game totali persi:"), style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
                        Text("$totaleGamePersi", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Barra progresso game
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percGameVintiBarra,
                    minHeight: 10,
                    backgroundColor: Colors.red.withValues(alpha: 0.2),
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
                  percentage: percentualeVittorieTotale,
                  detail: "${AppLocalizations.of(context)!.translate("su")} $totalePartite ${AppLocalizations.of(context)!.translate("partite")}",
                  valueCount: totaleVittorie,
                  color: Colors.blue[700]!,
                ),

                const SizedBox(height: 16),

                // 4. VITTORIE 30 GG
                _buildStatRow(
                  context,
                  label: AppLocalizations.of(context)!.translate("Vittorie (ultimi 30gg):"),
                  percentage: percentualeVittorieUltimi30Giorni,
                  detail: "${AppLocalizations.of(context)!.translate("su")} $totalePartiteUltimi30Giorni ${AppLocalizations.of(context)!.translate("partite")}",
                  valueCount: totaleVittorieUltimi30Giorni,
                  color: Colors.purple[700]!,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Bottone aggiungi statss
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () async {
                final nuovaPartita = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AggiungiPartitaStatistiche()),
                );
                if (nuovaPartita != null && nuovaPartita is Partita) {
                  aggiungiNuovaPartita(nuovaPartita);
                }
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                AppLocalizations.of(context)!.translate("Aggiungi nuova partita"),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: colorScheme.primary.withValues(alpha:0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 20),
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
                backgroundColor: color.withValues(alpha:0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(
              "${percentage.toStringAsFixed(0)}%",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(width: 16),

        // Testi
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label, // Vittorie totali:
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14),
                  children: [
                    TextSpan(
                        text: "$valueCount ",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)
                    ),
                    TextSpan(text: detail), // su X partite
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