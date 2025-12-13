class TorneoModel {
  final String guid;
  final String nomeTorneo;
  final String citta;
  final String provincia;
  final String tennisClub;
  final String dataInizio;
  final String dataFine;
  final String idFonte;
  final bool iscrizioneOnline;

  TorneoModel({
    required this.guid,
    required this.nomeTorneo,
    required this.citta,
    required this.provincia,
    required this.tennisClub,
    required this.dataInizio,
    required this.dataFine,
    required this.idFonte,
    required this.iscrizioneOnline,
  });
//i tornei provengono da una api esterna, per questo usiamo un json qui
  factory TorneoModel.fromJson(Map<String, dynamic> json) {
    return TorneoModel(
      guid: json['guid'] ?? '',
      nomeTorneo: json['nome_torneo'] ?? '',
      citta: json['citta'] ?? '',
      provincia: json['provincia'] ?? '',
      tennisClub: json['tennisclub'] ?? '',
      dataInizio: json['data_inizio'] ?? '',
      dataFine: json['data_fine'] ?? '',
      idFonte: json['id_fonte'] ?? '',
      iscrizioneOnline: json['iscrizione_online'] ?? false,
    );
  }
}