import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:matchup/UI/widgets/CustomSnackBar.dart';
import 'dart:async';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import 'package:matchup/UI/widgets/prenotaDaMappa.dart';
import '../../services/localizzazione.dart';

class MappaTennis extends StatefulWidget {
  const MappaTennis({Key? key}) : super(key: key);
  @override
  State<MappaTennis> createState() => _MappaTennisState();
}

class _MappaTennisState extends State<MappaTennis> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  LatLng _center = const LatLng(41.9028, 12.4964); // Default Roma
  bool _isReady = false; //Serve per aspettare il GPS all'avvio
  bool _mapRendered = false;
  List<Marker> _campiMarkers = [];
  Marker? _userLocationMarker;
  bool _isLoading = false;
  bool _mostraSuggerimenti = false;

  //Funzioni zoom
  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1);
  }

  Future<void> _goToUserLocation() async {
    setState(() => _isLoading = true);
    final Position? position = await LocationService.getCurrentPosition();
    if (position != null) {
      final userLatLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _mapController.move(userLatLng, 15.0);
        _userLocationMarker =
            Marker(
              point: userLatLng,
              width: 60,
              height: 60,
              child: const Icon(Icons.my_location, color: Colors.blueAccent, size: 30, shadows: [Shadow(blurRadius: 10, color: Colors.black26)],),
            );
      });
      _cercaCampiArea(centerOverride: userLatLng);
    } else {
      // Se position è null, significa che l'utente ha negato i permessi o il GPS è spento
      if(mounted) {
        CustomSnackBar.show(context, AppLocalizations.of(context)!.translate("Impossibile ottenere la posizione GPS"));
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _cercaIndirizzo() async {
    final String linguaCorrente = Localizations.localeOf(context).languageCode;
    final query = _searchController.text;
    if (query.isEmpty) return;

    //Chiude la tastiera
    FocusScope.of(context).unfocus();

    setState(() {
      _mostraSuggerimenti = false;
      _isLoading = true;
    });

    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1'
    );

    try {
      final response = await http.get(url, headers: {'User-Agent': 'com.matchup.app', 'Accept-Language': linguaCorrente,});

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          final newPos = LatLng(lat, lon);

          _mapController.move(newPos, 13.0);
          _cercaCampiArea(centerOverride: newPos);
        } else {
          CustomSnackBar.show(context, AppLocalizations.of(context)!.translate("Indirizzo non trovato"));
        }
      }
    } catch (e) {
      debugPrint("Errore Ricerca: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cercaCampiArea({LatLng? centerOverride}) async {
    if (!_mapRendered && centerOverride == null) {
      debugPrint("Map not ready: search aborted");
      return;
    }
    setState(() => _isLoading = true);

    final center = centerOverride ?? _mapController.camera.center;
    final lat = center.latitude;
    final lon = center.longitude;

    final query = '''
      [out:json];
      (
        node["sport"="tennis"](around:5000, $lat, $lon);
        way["sport"="tennis"](around:5000, $lat, $lon);
      );
      out center;
    ''';

    try {
      final url = Uri.parse('https://overpass-api.de/api/interpreter?data=$query');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List;

        setState(() {
          _campiMarkers = elements.map((e) {
            double lat = e['lat'] ?? e['center']['lat'];
            double lon = e['lon'] ?? e['center']['lon'];

            final tags = e['tags'] != null ? Map<String, dynamic>.from(e['tags']) : <String, dynamic>{};

            return Marker(
              point: LatLng(lat, lon),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () {
                  _mostraDettagliCampo(tags);
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.9),
                    border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                    boxShadow: const [BoxShadow(blurRadius: 5, color: Colors.black26)],
                  ),
                  child: Icon(
                      Icons.sports_tennis,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24
                  ),
                ),
              ),
            );
          }).toList();
        });

        if (elements.isNotEmpty && mounted) {
          CustomSnackBar.show(context,
              "${AppLocalizations.of(context)!.translate("Trovati")} ${elements.length} ${AppLocalizations.of(context)!.translate("campi!")}"
          );
        }
      }
    } catch (e) {
      debugPrint("Errore Overpass: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostraDettagliCampo(Map<String, dynamic> tags) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return prenotaDaMappa(tags);
        }
    );
  }

  @override
  void initState() {
    super.initState();
    _inizializzaMappaConGPS();
  }

  Future<void> _inizializzaMappaConGPS() async {
    // Chiamata al service di localizzazione
    final Position? position = await LocationService.getCurrentPosition();
    if (position != null) {
      _center = LatLng(position.latitude, position.longitude);
      _userLocationMarker = Marker(
        point: _center,
        width: 60,
        height: 60,
        child: Icon(Icons.my_location, color: Theme.of(context).colorScheme.primary, size: 30),
      );
      // Cerca campi nella posizione dell'utente
      _cercaCampiArea(centerOverride: _center);
    } else {
      // Fallback su Roma se il GPS non è disponibile
      _cercaCampiArea(centerOverride: _center);
    }

    if (mounted) {
      setState(() {
        _isReady = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_isReady)
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                onMapReady: () {
                  setState(() {
                    _mapRendered = true;
                  });
                },
                initialCenter: _center,
                initialZoom: 15.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [

                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
                ),

                MarkerLayer(
                  markers: [
                    ..._campiMarkers,
                    if (_userLocationMarker != null) _userLocationMarker!,
                  ],
                ),
              ],
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 15),
                  Text(
                      AppLocalizations.of(context)!.translate("Localizzazione in corso..."),
                      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ),

          //Barra di ricerca
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: _mostraSuggerimenti ? const BorderRadius.vertical(top: Radius.circular(12)) : BorderRadius.circular(12)
                  ),
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onSubmitted: (_) => _cercaIndirizzo(),
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.translate("Cerca città..."),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        if (_isLoading && _isReady)
                          const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        else
                          IconButton(
                            icon: const Icon(Icons.search, color: Colors.grey),
                            onPressed: _cercaIndirizzo,
                          ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),


          //Bottoni zoom
          Positioned(
            top: 120,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: "zoom_in",
                  onPressed: _zoomIn,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  child: Icon(Icons.add, color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: "zoom_out",
                  onPressed: _zoomOut,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  child: Icon(Icons.remove, color: Theme.of(context).colorScheme.onSurface),
                ),
              ],
            ),
          ),

          if (_isLoading)
            const Center(child: CircularProgressIndicator()),

          //Bottoni GPS e cerca area
          Positioned(
            bottom: 30,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: "gps_btn",
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  onPressed: _goToUserLocation,
                  child: Icon(Icons.my_location, color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(height: 16),
                FloatingActionButton.extended(
                  heroTag: "search_area_btn",
                  onPressed: () => _cercaCampiArea(),
                  label: Text(AppLocalizations.of(context)!.translate("Cerca qui")),
                  icon: const Icon(Icons.sports_tennis),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}