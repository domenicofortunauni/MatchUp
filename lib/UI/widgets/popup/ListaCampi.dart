import 'package:flutter/material.dart';
import 'package:matchup/model/objects/CampoModel.dart';
import 'package:matchup/UI/widgets/PrenotaCampo.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import '../../../services/campo_service.dart';
import '../../../services/localizzazione.dart';

class ListaCampiPopup extends StatefulWidget {
  const ListaCampiPopup({Key? key}) : super(key: key);
  @override
  State<ListaCampiPopup> createState() => _ListaCampiPopupState();
}

class _ListaCampiPopupState extends State<ListaCampiPopup> {
  final CampoService _campoService = CampoService();
  final TextEditingController _searchController = TextEditingController();

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
    setState(() {
      _myCity = city;
      _searchCity = city; // Inizialmente cerca nella città dell'utente
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

  // Gestione del click sul campo
  void _handleCampoTap(CampoModel campo,bool tipoPrenotazione) {
    //Chiude il popup
    Navigator.pop(context);

    //Apre la pagina di dettaglio per prenotare/sfidare
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrenotaCampo(campo: campo, tipoPrenotazione: tipoPrenotazione,),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Se la città non è ancora caricata, mostra loading
    if (_searchCity == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50, height: 5,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 20),

          // Titolo
          Text(
            AppLocalizations.of(context)!.translate("Scegli il campo"),
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 5),
          Text(AppLocalizations.of(context)!.translate("Seleziona una struttura per lanciare la sfida")),
          const SizedBox(height: 20),

          // Barra di Ricerca
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.translate("Cerca campo o città"),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(22)),
            ),
            onSubmitted: (value) => _fetchCampi(value),
          ),

          const SizedBox(height: 10),

          // Lista Campi
          Expanded(
            child: StreamBuilder<List<CampoModel>>(
              stream: _campoService.getCampi(_searchCity!),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text(AppLocalizations.of(context)!.translate("Errore nel caricamento")));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final List<CampoModel> tuttiICampi = snapshot.data ?? [];

                // Filtro locale basato sulla ricerca
                final List<CampoModel> campiFiltrati = tuttiICampi.where((campo) {
                  final nomeLower = campo.nome.toLowerCase();
                  final cittaLower = campo.citta.toLowerCase();
                  return nomeLower.contains(_searchQuery) || cittaLower.contains(_searchQuery);
                }).toList();

                if (campiFiltrati.isEmpty) {
                  return Center(child: Text(AppLocalizations.of(context)!.translate("Nessun campo presente a")+_searchCity!));
                }

                return ListView.separated(
                  itemCount: campiFiltrati.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1, indent: 70),
                  itemBuilder: (context, index) {
                    final campo = campiFiltrati[index];

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      // Avatar Campo
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        child: Icon(Icons.stadium, color: Theme.of(context).colorScheme.primary),
                      ),
                      // Nome Campo
                      title: Text(
                        campo.nome,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      // Info (Città + Rating + Prezzo)
                      subtitle: Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 2),
                          Text("${campo.citta} ", style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 5),
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          Text(" ${campo.rating}", style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      // Prezzo
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                                "€${campo.prezzoOrario.toStringAsFixed(0)}",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.bold
                                )
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
                        ],
                      ),
                      onTap: () => _handleCampoTap(campo,true),
                      //questo widget lo uso solo per sfida quindi va bene così in teoria
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}