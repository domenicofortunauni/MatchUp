import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class Torneo {
  final String guid;
  final String nomeTorneo;
  final String citta;
  final String provincia;
  final String tennisClub;
  final String dataInizio;
  final String dataFine;
  final String idFonte;
  final bool iscrizioneOnline;

  Torneo({
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

  factory Torneo.fromJson(Map<String, dynamic> json) {
    return Torneo(
      guid: json['guid'] ?? '',
      nomeTorneo: json['nome_torneo'] ?? 'Torneo non specificato',
      citta: json['citta'] ?? '',
      provincia: json['provincia'] ?? '',
      tennisClub: json['tennisclub'] ?? 'Club non specificato',
      dataInizio: json['data_inizio'] ?? '',
      dataFine: json['data_fine'] ?? '',
      idFonte: json['id_fonte'] ?? '',
      iscrizioneOnline: json['iscrizione_online'] ?? false,
    );
  }
}
class FitpService {
  static const String apiUrl = 'https://dp-myfit-test-function-v2.azurewebsites.net/api/v2/tornei/puc/list';

  Future<List<Torneo>> fetchTournaments(String freetext) async {
    final now = DateTime.now();
    final dataInizio = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    final body = jsonEncode({
      "guid": "",
      "profilazione": "",
      "freetext": freetext, // Testo di ricerca dinamico
      "id_regione": null,
      "id_provincia": null,
      "id_stato": null,
      "id_disciplina": 4332, // Tennis
      "sesso": null,
      "data_inizio": dataInizio, // Ora è la data odierna
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

    final headers = {
      'Accept': 'application/json, text/plain, */*',
      'Accept-Language': 'it-IT,it;q=0.9,en-US;q=0.8,en;q=0.7',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
      'Content-Type': 'application/json',
      'Origin': 'https://www.fitp.it',
      'Pragma': 'no-cache',
      'Referer': 'https://www.fitp.it/',
      'Sec-Fetch-Dest': 'empty',
      'Sec-Fetch-Mode': 'cors',
      'Sec-Fetch-Site': 'cross-site',
      'User-Agent':
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36',
      'sec-ch-ua':
      '"Chromium";v="142", "Google Chrome";v="142", "Not_A Brand";v="99"',
      'sec-ch-ua-mobile': '?0',
      'sec-ch-ua-platform': '"Windows"',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return [];
        }

        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> competizioniJson =
            jsonResponse['competizioni'] ?? [];
        return competizioniJson
            .map((json) => Torneo.fromJson(json))
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

class TorneiPage extends StatefulWidget {
  const TorneiPage({super.key});

  @override
  State<TorneiPage> createState() => _TorneiPageState();
}


class _TorneiPageState extends State<TorneiPage> {
  final FitpService _fitpService = FitpService();
  late Future<List<Torneo>> _futureTournaments;
  final TextEditingController _searchController = TextEditingController();

  String _currentSearchText = 'Caricamento posizione...';
  bool _isLoadingLocation = true; // Stato per il caricamento iniziale

  @override
  void initState() {
    super.initState();
    _futureTournaments = Future.value([]);
    _initializeLocationAndFetch();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('I permessi di localizzazione sono stati negati.');
      }
    }
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('I servizi di localizzazione sono disabilitati.');
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'I permessi di localizzazione sono stati negati per sempre. Devi abilitarli dalle impostazioni.');
    }
    return await Geolocator.getCurrentPosition();
  }
  Future<String> _getAddressFromLatLon(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return placemark.locality ?? placemark.subAdministrativeArea ??'Cosenza';
      }
      return 'Cosenza';
    } catch (e) {
      print('Errore Geocoding: $e');
      return 'Cosenza';
    }
  }

  void _initializeLocationAndFetch() async {
    try {
      final position = await _determinePosition();
      final city = await _getAddressFromLatLon(position);
      setState(() {
        _currentSearchText = city;
        _searchController.text = city;
        _isLoadingLocation = false;
        _fetchTournaments(city);
      });

    } catch (e) {
      final fallbackCity = 'Cosenza';
      setState(() {
        _currentSearchText = fallbackCity;
        _searchController.text = fallbackCity;
        _isLoadingLocation = false;
        _futureTournaments = Future.value([]);
      });
      print('Errore di geolocalizzazione: $e');
    }
  }

  // Funzione per aggiornare la ricerca quando l'utente preme Cerca
  void _fetchTournaments(String freetext) {
    setState(() {
      _currentSearchText = freetext;
      _futureTournaments = _fitpService.fetchTournaments(freetext);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    // Disabilita l'input se la posizione è ancora in caricamento
                    enabled: !_isLoadingLocation,
                    decoration: InputDecoration(
                      labelText: _isLoadingLocation ? 'Localizzazione in corso...' : 'Cerca città o provincia',
                      hintText: 'es. Cosenza, Roma',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14.0, horizontal: 16.0),
                    ),
                    onSubmitted: (value) => _fetchTournaments(value),
                  ),
                ),
                const SizedBox(width: 10),
                // Bottone di ricerca stilizzato
                ElevatedButton(
                  onPressed: _isLoadingLocation
                      ? null // Disabilita il bottone se la posizione è in caricamento
                      : () {
                    _fetchTournaments(_searchController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Cerca',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // Indicatore della città attualmente cercata e Loading
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoadingLocation)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: theme.primaryColor),
                  ),
                if (_isLoadingLocation) const SizedBox(width: 8),
                Text(
                  'Risultati per: $_currentSearchText',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Lista dei Tornei
          Expanded(
            child: FutureBuilder<List<Torneo>>(
              future: _futureTournaments,
              builder: (context, snapshot) {
                if (_isLoadingLocation) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: theme.primaryColor),
                        const SizedBox(height: 16),
                        const Text('Ricerca tornei in base alla tua posizione...'),
                      ],
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Si è verificato un errore: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: theme.colorScheme.error, fontSize: 16),
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sports_tennis_outlined, size: 80, color: theme.primaryColor.withOpacity(0.6)),
                        const SizedBox(height: 16),
                        const Text(
                          'Nessun torneo trovato per questa località o data.',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  );
                } else {
                  return ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final torneo = snapshot.data![index];
                      return TorneoCard(torneo: torneo, isDark: isDark);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
class TorneoCard extends StatelessWidget {
  final Torneo torneo;
  final bool isDark;

  const TorneoCard({
    super.key,
    required this.torneo,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.colorScheme.surfaceContainerHigh;
    final textColor = theme.colorScheme.inverseSurface;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0)
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              torneo.nomeTorneo,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.inverseSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Dal ${torneo.dataInizio} al ${torneo.dataFine}',
                  style: theme.textTheme.titleSmall?.copyWith(color: textColor),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  '${torneo.citta} (${torneo.provincia})',
                  style: theme.textTheme.titleSmall?.copyWith(color: textColor),
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              'Organizzato da:',
              style: theme.textTheme.labelMedium?.copyWith(
                color: textColor.withValues(alpha:0.7),
              ),
            ),
            Text(
              torneo.tennisClub,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),

            // INFO EXTRA (Fonte e Iscrizione)
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                // fonte (FITP/TPRA)
                _buildInfoChip(
                  context,
                  label: torneo.idFonte,
                  icon: Icons.sports_tennis,
                  color: Theme.of(context).colorScheme.primary,
                  textColor: Colors.white,
                ),
                // Chip per l'iscrizione online
                if (torneo.iscrizioneOnline)
                  _buildInfoChip(
                    context,
                    label: 'Iscrizione Online',
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                    textColor: Colors.white,
                  )
                else
                  _buildInfoChip(
                    context,
                    label: 'Iscrizione in loco',
                    icon: Icons.cancel_outlined,
                    color: Colors.red,
                    textColor: Colors.white,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
      BuildContext context, {
        required String label,
        required IconData icon,
        required Color color,
        required Color textColor,
      }) {
    return Chip(
      avatar: Icon(icon, size: 18, color: textColor),
      label: Text(label,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
      backgroundColor: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }
}