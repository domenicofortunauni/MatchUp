class CampoModel {
  final String nome;
  final String indirizzo;
  final String citta;
  final double prezzoOrario;
  final double rating;
  final String imageUrl;

  CampoModel({
    required this.nome,
    required this.indirizzo,
    required this.citta,
    required this.prezzoOrario,
    required this.rating,
    this.imageUrl = "",
  });
}
