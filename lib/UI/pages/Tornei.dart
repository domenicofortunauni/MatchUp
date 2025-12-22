import 'package:flutter/material.dart';
import 'dart:async';
import "package:matchup/model/objects/TorneoModel.dart";
import "../behaviors/AppLocalizations.dart";
import "../widgets/EmptyWidget.dart";
import "../widgets/cards/TorneoCard.dart";
import "../../services/sito_tornei.dart";
import "../../services/localizzazione.dart";
import "../widgets/search_bar.dart";

class TorneiPage extends StatefulWidget {
  const TorneiPage({super.key});

  @override
  State<TorneiPage> createState() => _TorneiPageState();
}

class _TorneiPageState extends State<TorneiPage> {
  final FitpService _fitpService = FitpService();
  final TextEditingController _searchController = TextEditingController();

  List<TorneoModel> _tournaments = [];
  bool _isLoading = false;
  bool _isLoadingLocation = true;
  String _currentSearchText = "";
  String? _error;

  @override
  void initState() {
    super.initState();
    _initData();
  }
  // Carica città iniziale e tornei
  Future<void> _initData() async {
    try {
      final city = await LocationService.getMyCity();
      if (!mounted) return;

      _searchController.text = city;
      _currentSearchText = city;
      _isLoadingLocation = false;

      await _fetchTournaments(city);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingLocation = false;
        _error = e.toString();
      });
    }
  }

  // Fetch tornei
  Future<void> _fetchTournaments(String freetext) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _currentSearchText = freetext;
    });
    try {
      final result = await _fitpService.fetchTournaments(freetext);
      if (!mounted) return;
      setState(() {
        _tournaments = result;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _tournaments = [];
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
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
          _buildSearchBar(),
          _buildStatusHeader(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: MySearchBar(
        controller: _searchController,
        onSearch: _fetchTournaments,
        enabled: !_isLoadingLocation,
        primaryColor: Theme.of(context).colorScheme.primary,
        //i testi vengono tradotti nel widget
        labelKey: _isLoadingLocation ? "Localizzazione..." : "Cerca città",
        hintKey: "es. Roma",
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isLoadingLocation || _isLoading) ...[
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
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
    if (_isLoadingLocation)
      return const SizedBox();

    if (_isLoading)
      return const Center(child: CircularProgressIndicator());

    if (_error != null || _tournaments.isEmpty) {
      return Center(
        child: EmptyWidget(
          text: AppLocalizations.of(context)!.translate("Nessun torneo trovato."),
          subText: AppLocalizations.of(context)!.translate("Prova a cercare in un'altra città."),
          icon: Icons.sports_tennis_outlined,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: _tournaments.length,
      itemBuilder: (context, index) {
        return TorneoCard(
          torneo: _tournaments[index],
        );
      },
    );
  }
}