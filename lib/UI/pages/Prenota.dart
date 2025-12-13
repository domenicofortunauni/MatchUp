import 'package:flutter/material.dart';
import 'package:matchup/model/objects/CampoModel.dart';
import 'package:matchup/UI/widgets/MappaTennis.dart';
import '../../services/campo_service.dart';
import '../../services/localizzazione.dart';
import '../../services/meteo_service.dart';
import '../widgets/cards/CampoPrenotabileCard.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';

class Prenota extends StatefulWidget {
  const Prenota({Key? key}) : super(key: key);

  @override
  State<Prenota> createState() => _PrenotaState();
}

class _PrenotaState extends State<Prenota> {
  final CampoService _campoService = CampoService();
  final TextEditingController _searchController = TextEditingController();

  bool? pioveOggi; // null se non ancora verificato, true se piove
  String _searchQuery = "";
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
    bool meteo = false;
    if (city.isNotEmpty) {
      meteo = await MeteoService.isRainExpected(city, DateTime.now());
    }

    setState(() {
      _myCity = city;
      _searchCity = city;
      pioveOggi = meteo;
    });
  }
  void _fetchCampi(String searchText) {
    setState(() {
      if (searchText.trim().isNotEmpty) {
        _searchCity = searchText.trim();
      } else {
        _searchCity = _myCity; // Se vuoto, torna alla mia città
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final Color surfaceColor = Theme.of(context).colorScheme.surface;

    // Se la città non è ancora caricata, mostra loading
    if (_searchCity == null) {
      return Scaffold(
        backgroundColor: surfaceColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: surfaceColor,
      body: StreamBuilder<List<CampoModel>>(
        stream: _campoService.getCampi(_searchCity!),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "${AppLocalizations.of(context)!.translate("Errore nel caricamento: ")}${snapshot.error}",
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final List<CampoModel> tuttiICampi = snapshot.data ?? [];
          final List<CampoModel> campiFiltrati = tuttiICampi.where((campo) {
            final nomeLower = campo.nome.toLowerCase();
            final cittaLower = campo.citta.toLowerCase();
            final searchLower = _searchQuery.toLowerCase();
            return nomeLower.contains(searchLower) || cittaLower.contains(searchLower);
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120.0),
            child: Card(
              elevation: 0,
              margin: const EdgeInsets.all(12.0),
              color: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.translate('Prenota un campo'),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MappaTennis()),
                        );
                      },
                      icon: const Icon(Icons.map_outlined),
                      label: Text(AppLocalizations.of(context)!.translate("Cerca campi su mappa")),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryColor,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                          side: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // BARRA DI RICERCA
                    Row(
                      children: [
                        Expanded(
                          child:
                            TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.translate('Cerca campo o città'),
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(22)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onSubmitted: (value) => _fetchCampi(value),
                          ),),
                        const SizedBox(width: 10),
                        ElevatedButton(
                      onPressed:() {
                        _fetchCampi(_searchController.text);
                        },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(AppLocalizations.of(context)!.translate("Cerca")),
                      ),
                        ],
                    ),
                    const SizedBox(height: 10),
                    if (campiFiltrati.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Center(
                          child: Text(
                            tuttiICampi.isEmpty
                                ? AppLocalizations.of(context)!.translate("Nessun campo presente a")+_searchCity!
                                : AppLocalizations.of(context)!.translate("Nessun risultato per la ricerca."),
                            style: TextStyle(color: onSurfaceColor.withValues(alpha: 0.6)),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: campiFiltrati.length,
                        itemBuilder: (context, index) {
                          final campo = campiFiltrati[index];
                          return CampoCard(campo: campo,isRainExpected: pioveOggi==true,);
                        },
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}