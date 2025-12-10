class NotiziaModel {
  final String titolo;
  final String descrizione;
  final String urlImmagine;
  final String fonte;
  final String urlArticolo;

  NotiziaModel({
    required this.titolo,
    required this.descrizione,
    required this.urlImmagine,
    required this.fonte,
    required this.urlArticolo,
  });
  factory NotiziaModel.fromJson(Map<String, dynamic> json) {
    return NotiziaModel(
      titolo: json['title'] ?? '',
      descrizione: json['description'] ?? '',
      urlImmagine: json['image'],
      fonte: json['source']?['name'] ?? '',
      urlArticolo: json['url'] ?? '',
    );
  }
}
