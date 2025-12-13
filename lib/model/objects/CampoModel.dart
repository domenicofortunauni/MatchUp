import 'package:cloud_firestore/cloud_firestore.dart';

class CampoModel {
  final String id;
  final String nome;
  final String indirizzo;
  final String citta;
  final double prezzoOrario;
  final double rating;
  final List<String> campiDisponibili;
  final bool campoAlCoperto;

  CampoModel({
    required this.id,
    required this.nome,
    required this.indirizzo,
    required this.citta,
    required this.prezzoOrario,
    required this.rating,
    required this.campiDisponibili,
    required this.campoAlCoperto,

  });

  factory CampoModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CampoModel(
      id: doc.id,
      nome: data['nome'] ?? 'Campo sconosciuto', //no applocalizations qui! lo gestisco dopo
      indirizzo: data['indirizzo'] ?? '',
      citta: data['citta'] ?? '',
      prezzoOrario: (data['prezzoOrario'] ?? 0).toDouble(),
      rating: (data['rating'] ?? 0).toDouble(),
      campiDisponibili: List<String>.from(data['campiDisponibili'] ?? ['Campo Standard']),
      campoAlCoperto: data['campoAlCoperto'] ?? false, // default false se non presente
    );
  }
}