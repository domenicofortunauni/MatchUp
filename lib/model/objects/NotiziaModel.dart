class Notizia {
  final String titolo;
  final String descrizione;
  final String urlImmagine;
  final String fonte;
  final String urlArticolo;

  Notizia({
    required this.titolo,
    required this.descrizione,
    required this.urlImmagine,
    required this.fonte,
    required this.urlArticolo,
  });
  factory Notizia.fromJson(Map<String, dynamic> json) {
    return Notizia(
      titolo: json['title'] ?? '',
      descrizione: json['description'] ?? '',
      urlImmagine: json['image'],
      fonte: json['source']?['name'] ?? '',
      urlArticolo: json['url'] ?? '',
    );
  }
}
