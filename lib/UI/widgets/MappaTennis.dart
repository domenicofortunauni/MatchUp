import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Motore mappa
import 'package:latlong2/latlong.dart';       // Coordinate
import 'package:http/http.dart' as http;      // API
import 'package:geolocator/geolocator.dart';  // GPS
import 'package:matchup/UI/widgets/CustomSnackBar.dart';
import 'dart:async';

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

  List<Marker> _campiMarkers = [];
  Marker? _userLocationMarker;
  bool _isLoading = false;

  List<dynamic> _suggerimenti = [];
  Timer? _debounce;
  bool _mostraSuggerimenti = false;
  bool _ignoraSuggerimentiInArrivo = false;

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

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoading = false);
        return;
      }
    }

    try {
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      Position position = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings
      );

      final userLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _mapController.move(userLatLng, 15.0);

        _userLocationMarker = Marker(
          point: userLatLng,
          width: 60,
          height: 60,
          child: const Icon(
            Icons.my_location,
            color: Colors.blueAccent,
            size: 30,
            shadows: [Shadow(blurRadius: 10, color: Colors.black26)],
          ),
        );
      });

      _cercaCampiArea(centerOverride: userLatLng);

    } catch (e) {
      debugPrint("Errore GPS: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cercaIndirizzo() async {
    final String linguaCorrente = Localizations.localeOf(context).languageCode;
    final query = _searchController.text;
    if (query.isEmpty) return;

    _ignoraSuggerimentiInArrivo = true;
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    //Chiude la tastiera
    FocusScope.of(context).unfocus();

    setState(() {
      _mostraSuggerimenti = false;
      _suggerimenti = [];
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
            CustomSnackBar.show(context, "Indirizzo non trovato",
          );
        }
      }
    } catch (e) {
      debugPrint("Errore Ricerca: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    _ignoraSuggerimentiInArrivo = false;

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      // Se la query è troppo corta, chiude tutto
      if (query.length < 3) {
        setState(() {
          _suggerimenti = [];
          _mostraSuggerimenti = false;
        });
        return;
      }

      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5'
      );

      try {
        final response = await http.get(url, headers: {'User-Agent': 'com.matchup.app'});
        if (_ignoraSuggerimentiInArrivo) return;
        if (response.statusCode == 200) {
          setState(() {
            _suggerimenti = json.decode(response.body);
            _mostraSuggerimenti = true;
          });
        }
      } catch (e) {
        debugPrint("Errore API suggerimenti: $e");
      }
    });
  }

  void _selezionaSuggerimento(dynamic luogo) {
    _ignoraSuggerimentiInArrivo = true; //Blocca eventuali altre richieste
    final lat = double.parse(luogo['lat']);
    final lon = double.parse(luogo['lon']);
    final displayName = luogo['display_name'];

    setState(() {
      _searchController.text = displayName;
      _suggerimenti = [];
      _mostraSuggerimenti = false;

      final newPos = LatLng(lat, lon);
      _mapController.move(newPos, 14.0);
    });

    //Cerca i campi da tennis nella nuova zona
    _cercaCampiArea(centerOverride: LatLng(lat, lon));
  }

  Future<void> _cercaCampiArea({LatLng? centerOverride}) async {
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
                    border: Border.all(color: Colors.deepOrange, width: 2),
                    boxShadow: const [BoxShadow(blurRadius: 5, color: Colors.black26)],
                  ),
                  child: const Icon(
                      Icons.sports_tennis,
                      color: Colors.deepOrange,
                      size: 24
                  ),
                ),
              ),
            );
          }).toList();
        });

        if (elements.isNotEmpty && mounted) {
          CustomSnackBar.show(context, "Trovati ${elements.length} campi!",
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
    final nome = tags['name'] ?? 'Campo da Tennis';
    final surface = tags['surface'] ?? 'Non specificata';
    final access = tags['access'] ?? 'Pubblico';
    final operator = tags['operator'] ?? 'Non specificato';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.sports_tennis, size: 40, color: Colors.deepOrange),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nome,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          operator != 'Non specificato' ? operator : "Gestore sconosciuto",
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 30),

              ListTile(
                leading: const Icon(Icons.grass),
                title: const Text("Superficie"),
                subtitle: Text(surface.toUpperCase()),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
              ListTile(
                leading: const Icon(Icons.lock_open),
                title: const Text("Accesso"),
                subtitle: Text(access == 'private' ? "Privato / Circolo" : "Pubblico"),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    CustomSnackBar.show(context,"Funzione prenota in arrivo...",
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("PRENOTA QUESTO CAMPO"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _inizializzaMappaConGPS();
  }

  Future<void> _inizializzaMappaConGPS() async {
    bool gpsTrovato = false;

    //Controlliamo i permessi
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      try {
        Position? position;
        try {
          position = await Geolocator.getLastKnownPosition();
        } catch (e) {
          }

        if (position == null) {
          const LocationSettings locationSettings = LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10), //Diamo 10 secondi per cliccare "Consenti"
          );

          position = await Geolocator.getCurrentPosition(locationSettings: locationSettings);
        }

        _center = LatLng(position.latitude, position.longitude);
        gpsTrovato = true;

      } catch (e) {
        debugPrint("GPS fallito: $e. Uso Roma come fallback.");
      }
    }

    if (gpsTrovato) {
      _userLocationMarker = Marker(
        point: _center,
        width: 60,
        height: 60,
        child: const Icon(Icons.my_location, color: Colors.blueAccent, size: 30),
      );
      _cercaCampiArea(centerOverride: _center);
    } else {
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
                initialCenter: _center,
                initialZoom: 15.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.matchup.app',
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
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 15),
                  Text(
                      "Localizzazione in corso...",
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)
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
                      borderRadius: _mostraSuggerimenti
                          ? const BorderRadius.vertical(top: Radius.circular(12))
                          : BorderRadius.circular(12)
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
                            onChanged: _onSearchChanged,
                            onSubmitted: (_) => _cercaIndirizzo(),
                            decoration: const InputDecoration(
                              hintText: "Cerca città...",
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

                if (_mostraSuggerimenti && _suggerimenti.isNotEmpty)
                  Container(
                    color: Colors.white,
                    constraints: const BoxConstraints(maxHeight: 200), //Altezza massima della tendina
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _suggerimenti.length,
                      separatorBuilder: (ctx, i) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final luogo = _suggerimenti[index];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.location_on_outlined, size: 20),
                          title: Text(
                            luogo['display_name'].split(',')[0],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                              luogo['display_name'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis
                          ),
                          onTap: () => _selezionaSuggerimento(luogo),
                        );
                      },
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
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.add, color: Colors.black),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: "zoom_out",
                  onPressed: _zoomOut,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.remove, color: Colors.black),
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
                  backgroundColor: Colors.white,
                  onPressed: _goToUserLocation,
                  child: const Icon(Icons.my_location, color: Colors.blue),
                ),
                const SizedBox(height: 16),
                FloatingActionButton.extended(
                  heroTag: "search_area_btn",
                  onPressed: () => _cercaCampiArea(),
                  label: const Text("Cerca qui"),
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