import "dart:convert";
import "package:http/http.dart" as http;
import "package:intl/intl.dart";
import "../model/objects/TorneoModel.dart";
import "../model/support/Constants.dart";

class FitpService {
  Future<List<TorneoModel>> fetchTournaments(String freetext) async {
    final now = DateTime.now();
    final dataInizio = DateFormat('dd/MM/yyyy').format(now);
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final body = jsonEncode({
      "guid": "",
      "profilazione": "",
      "freetext": freetext, // Testo di ricerca per la città!
      "id_regione": null,
      "id_provincia": null,
      "id_stato": null,
      "id_disciplina": 4332, // Tennis , ottenuto da analisi di richiesta da web
      "sesso": null,
      "data_inizio": dataInizio,
      "data_fine": null,
      "tipo_competizione": null,
      "categoria_eta": null,
      "id_classifica": null,
      "classifica": null,
      "massimale_montepremi": null,
      "id_area_regionale": null,
      "ambito": null,
      "rowstoskip": 0,
      "fetchrows": 25,
      "sortcolumn": "data_inizio",
      "sortorder": "asc"
    });

    try {
      final response = await http.post(
        Uri.parse(Constants.API_TORNEI_URL),
        headers: headers,
        body: body,
      );
      if (response.statusCode == 200 ||response.statusCode == 500 ) {
        if (response.body.isEmpty) {
          return [];
        }
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> competizioniJson =
            jsonResponse['competizioni'] ?? [];
        return competizioniJson
            .map((json) => TorneoModel.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Errore durante il caricamento dei tornei: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Impossibile connettersi o elaborare i dati: $e');
    }
  }
}