import 'package:flutter/material.dart';
import 'package:matchup/model/objects/CampoModel.dart';
import 'package:matchup/UI/widgets/MappaTennis.dart';
import '../../services/campo_service.dart';
import '../../services/localizzazione.dart';
import '../../services/meteo_service.dart';
import '../widgets/EmptyWidget.dart';
import '../widgets/cards/CampoPrenotabileCard.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import '../widgets/search_bar.dart';

class Prenota extends StatefulWidget {
  const Prenota({Key? key}) : super(key: key);

  @override
  State<Prenota> createState() => _PrenotaState();
}

class _PrenotaState extends State<Prenota> {
  final CampoService _campoService = CampoService();
  final TextEditingController _searchController = TextEditingController();

  bool? pioveOggi; // null se non ancora verificato, true se piove
  String? _myCity;
  String? _searchCity; // Città da cercare (può essere diversa dalla mia)

  @override
  void initState() {
    super.initState();
    _loadCity();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  void _loadCity() async {
    final city = await LocationService.getMyCity();
    final meteo = await MeteoService.isRainExpected(city, DateTime.now(),);
    setState(() {
      pioveOggi = meteo;
      _myCity = city;
      _searchCity = city;
      _searchController.text = city;
    });
  }
  void _fetchCampi(String searchText) async {
    final city = searchText.trim().isNotEmpty ? searchText.trim() : _myCity;
    if (city == null) return;
    final meteo = await MeteoService.isRainExpected(city, DateTime.now(),);
    debugPrint(
      'METEO INIT | city=$city piove=$meteo date=${DateTime.now()}',
    );
    setState(() {
      pioveOggi = meteo;
      _searchCity = city;
    });
  }
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    if (_searchCity == null) {
      return Scaffold(
        backgroundColor: surfaceColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: surfaceColor,
      body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!
                        .translate('Prenota un campo'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MappaTennis(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.map_outlined),
                  label: Text(
                    AppLocalizations.of(context)!
                        .translate("Cerca campi su mappa"),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                      side: BorderSide(
                        color: primaryColor.withValues(alpha: 0.5),
                      ),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              MySearchBar(
                controller: _searchController,
                onSearch: _fetchCampi,
                primaryColor: primaryColor,
              ),

              const SizedBox(height: 20),

              Expanded(
                child: StreamBuilder<List<CampoModel>>(
                  stream: _campoService.getCampi(_searchCity!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          AppLocalizations.of(context)!.translate("Errore nel caricamento: ") + "${snapshot.error}",),
                      );
                    }

                    final campi = snapshot.data ?? [];

                    if (campi.isEmpty) {
                      return Center(
                        child: EmptyWidget(
                          text: AppLocalizations.of(context)!.translate("Nessun campo presente a") + _searchCity!,
                          subText: AppLocalizations.of(context)!.translate("Prova a cercare in un'altra città."),
                          icon: Icons.sports_tennis_outlined,
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: campi.length,
                      itemBuilder: (context, index) {
                        return CampoCard(
                          campo: campi[index],
                          isRainExpected: pioveOggi ?? false,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
    );
  }
}