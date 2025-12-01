import 'package:flutter/material.dart';
import 'dart:async';
import "package:matchup/model/objects/TorneoModel.dart";
import "../behaviors/AppLocalizations.dart";
import "../widgets/cards/TorneoCard.dart";
import "../../services/sito_tornei.dart";
import "../../services/localizzazione.dart";

class TorneiPage extends StatefulWidget {
  const TorneiPage({super.key});

  @override
  State<TorneiPage> createState() => _TorneiPageState();
}

class _TorneiPageState extends State<TorneiPage> {
  final FitpService _fitpService = FitpService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<Torneo>> _futureTournaments;
  String _currentSearchText = 'Caricamento...';
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _futureTournaments = Future.value([]); /
    _initData();
  }

  void _initData() async {
    final city = await LocationService.getCurrentCity(defaultCity: 'Roma');

    if (mounted) {
      setState(() {
        _currentSearchText = city;
        _searchController.text = city;
        _isLoadingLocation = false;
        _fetchTournaments(city);
      });
    }
  }

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
    return Scaffold(
      body: Column(
        children: [
          _buildSearchBar(),      // Barra di ricerca estratta
          _buildStatusHeader(),   // Intestazione estratta
          Expanded(child: _buildList()), // Lista estratta
        ],
      ),
    );
  }


  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16,16,16,8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              enabled: !_isLoadingLocation,
              decoration: InputDecoration(
                labelText: _isLoadingLocation ? AppLocalizations.of(context)!.translate("Localizzazione...") : AppLocalizations.of(context)!.translate("Cerca città"),
                hintText: 'es. Roma',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
              onSubmitted: _fetchTournaments,
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: _isLoadingLocation ? null : () => _fetchTournaments(_searchController.text),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(AppLocalizations.of(context)!.translate("Cerca")),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isLoadingLocation) ...[
            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 8),
          ],
          Text(
            AppLocalizations.of(context)!.translate("Risultati per:") + " $_currentSearchText",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_isLoadingLocation) return const SizedBox(); // O un loader vuoto

    return FutureBuilder<List<Torneo>>(
      future: _futureTournaments,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(AppLocalizations.of(context)!.translate("Errore:") + " ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports_tennis_outlined, size: 80, color: Theme.of(context).primaryColor.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text(AppLocalizations.of(context)!.translate("Nessun torneo trovato.")),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100), //
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            return TorneoCard(
              torneo: snapshot.data![index],
              isDark: Theme.of(context).brightness == Brightness.dark,
            );
          },
        );
      },
    );
  }
}