import 'package:flutter/material.dart';
import 'package:matchup/model/objects/CampoModel.dart';
import 'package:matchup/UI/widgets/prenota/MappaTennis.dart';
import '../../services/campo_service.dart';
import '../widgets/cards/CampoPrenotabileCard.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';

class Prenota extends StatefulWidget {
  const Prenota({Key? key}) : super(key: key);

  @override
  State<Prenota> createState() => _PrenotaState();
}

class _PrenotaState extends State<Prenota> {
  final CampoService _campoService = CampoService();

  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final Color surfaceColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: surfaceColor,
      body: StreamBuilder<List<CampoModel>>(
        stream: _campoService.getCampi(),
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
                        borderRadius: BorderRadius.circular(12),
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

                    // BOTTONE MAPPA
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MappaTennis()),
                        );
                      },
                      icon: const Icon(Icons.map_outlined),
                      label: Text(AppLocalizations.of(context)!.translate("Cerca Campi su Mappa")),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryColor,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      style: TextStyle(color: onSurfaceColor),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.translate('Cerca campo o città...'),
                        labelStyle: TextStyle(color: onSurfaceColor.withValues(alpha: 0.6)),
                        prefixIcon: Icon(Icons.search, color: onSurfaceColor.withValues(alpha: 0.6)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: onSurfaceColor.withValues(alpha: 0.05),
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (campiFiltrati.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Center(
                          child: Text(
                              tuttiICampi.isEmpty
                                  ? AppLocalizations.of(context)!.translate("Nessun campo presente nel database.")
                                  : AppLocalizations.of(context)!.translate("Nessun risultato per la ricerca."),
                              style: TextStyle(color: onSurfaceColor.withValues(alpha: 0.6))
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
                          return CampoCard(campo: campo);
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