import 'package:flutter/material.dart';
import 'package:matchup/model/CampoModel.dart';
import 'package:matchup/UI/widgets/DettaglioPrenotazione.dart';
import 'package:matchup/UI/widgets/MappaTennis.dart';

// Modello dati per il campo

class Prenota extends StatefulWidget {
  const Prenota({Key? key}) : super(key: key);

  @override
  State<Prenota> createState() => _PrenotaState();
}

class _PrenotaState extends State<Prenota> {
  // Lista fittizia di campi
  final List<CampoModel> _tuttiICampi = [
    CampoModel(nome: "Tennis Club Napoli", indirizzo: "Via Caracciolo, 10", citta: "Napoli", prezzoOrario: 20.0, rating: 4.5),
    CampoModel(nome: "Padel Arena", indirizzo: "Viale Kennedy, 54", citta: "Napoli", prezzoOrario: 35.0, rating: 4.8),
    CampoModel(nome: "Sporting Milano 3", indirizzo: "Piazza Marco Polo", citta: "Milano", prezzoOrario: 25.0, rating: 4.2),
    CampoModel(nome: "Roma Padel Center", indirizzo: "Via Olimpica, 5", citta: "Roma", prezzoOrario: 30.0, rating: 4.6),
    CampoModel(nome: "Circolo del Tennis", indirizzo: "Via dei Pini, 12", citta: "Firenze", prezzoOrario: 18.0, rating: 4.0),
  ];

  List<CampoModel> _campiFiltrati = [];

  @override
  void initState() {
    super.initState();
    _campiFiltrati = _tuttiICampi;
  }

  void _filterList(String query) {
    final results = _tuttiICampi.where((campo) {
      final nomeLower = campo.nome.toLowerCase();
      final cittaLower = campo.citta.toLowerCase();
      final searchLower = query.toLowerCase();
      return nomeLower.contains(searchLower) || cittaLower.contains(searchLower);
    }).toList();

    setState(() {
      _campiFiltrati = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final Color surfaceColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: surfaceColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120.0),
        child: Card(
          elevation: 4.0,
          margin: const EdgeInsets.all(12.0),
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
                      'Prenota un Campo',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // --- NUOVO BOTTONE MAPPA ---
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MappaTennis()),
                    );
                  },
                  icon: const Icon(Icons.map_outlined),
                  label: const Text("Cerca Campi su Mappa"),
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

                // BARRA DI RICERCA
                TextField(
                  onChanged: _filterList,
                  style: TextStyle(color: onSurfaceColor),
                  decoration: InputDecoration(
                    labelText: 'Cerca campo o città...',
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

                // LISTA CAMPI
                if (_campiFiltrati.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                          "Nessun campo trovato.",
                          style: TextStyle(color: onSurfaceColor.withValues(alpha: 0.6))
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _campiFiltrati.length,
                    itemBuilder: (context, index) {
                      final campo = _campiFiltrati[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DettaglioPrenotazione(campo: campo),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                // Icona/Immagine del campo
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.sports_tennis, size: 40, color: primaryColor),
                                ),
                                const SizedBox(width: 16),

                                // Info Campo
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        campo.nome,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: onSurfaceColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on, size: 14, color: onSurfaceColor.withValues(alpha: 0.5)),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              "${campo.indirizzo}, ${campo.citta}",
                                              style: TextStyle(
                                                  color: onSurfaceColor.withValues(alpha: 0.6),
                                                  fontSize: 13
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.star, size: 16, color: Colors.amber),
                                              const SizedBox(width: 4),
                                              Text(
                                                campo.rating.toString(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: onSurfaceColor
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            "€${campo.prezzoOrario.toStringAsFixed(0)}/h",
                                            style: TextStyle(
                                              color: primaryColor, // Prezzo evidenziato col colore principale
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: onSurfaceColor.withValues(alpha: 0.4)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}