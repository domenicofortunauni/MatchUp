class Partita {
  final String avversario;
  final int gameVinti;
  final int gamePersi;
  final int setVinti;
  final int setPersi;
  final bool isVittoria;
  final DateTime data;

  Partita({
    required this.avversario,
    required this.gameVinti,
    required this.gamePersi,
    required this.setVinti,
    required this.setPersi,
    required this.isVittoria,
    required this.data,
  });
}