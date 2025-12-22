import 'PartitaModel.dart';

class StatisticheModel {
  final int totalePartite;
  final int totaleVittorie;
  final int totaleGameVinti;
  final int totaleGamePersi;

  final int partiteUltimi30;
  final int vittorieUltimi30;

  final double percVittorieTotali;
  final double percVittorieUltimi30;
  final double percGameVinti;

  StatisticheModel({
    required this.totalePartite,
    required this.totaleVittorie,
    required this.totaleGameVinti,
    required this.totaleGamePersi,
    required this.partiteUltimi30,
    required this.vittorieUltimi30,
    required this.percVittorieTotali,
    required this.percVittorieUltimi30,
    required this.percGameVinti,
  });

  factory StatisticheModel.fromPartite(List<PartitaModel> partite) {
    final now = DateTime.now();
    final limite = now.subtract(const Duration(days: 30));

    int vittorie = 0;
    int gameVinti = 0;
    int gamePersi = 0;
    int p30 = 0;
    int v30 = 0;

    for (final p in partite) {
      gameVinti += p.gameVinti;
      gamePersi += p.gamePersi;

      if (p.isVittoria) {
        vittorie++;
      }

      if (p.data.isAfter(limite)) {
        p30++;
        if (p.isVittoria) {
          v30++;
        }
      }
    }

    final totale = partite.length;
    final totaleGame = gameVinti + gamePersi;

    return StatisticheModel(
      totalePartite: totale,
      totaleVittorie: vittorie,
      totaleGameVinti: gameVinti,
      totaleGamePersi: gamePersi,
      partiteUltimi30: p30,
      vittorieUltimi30: v30,
      percVittorieTotali: totale == 0 ? 0 : (vittorie / totale) * 100,
      percVittorieUltimi30: p30 == 0 ? 0 : (v30 / p30) * 100,
      percGameVinti: totaleGame == 0 ? 0 : gameVinti / totaleGame,
    );
  }
}