import 'package:flutter/material.dart';
import 'package:matchup/UI/widgets/StoricoPartite.dart';
import 'package:intl/intl.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';

class AggiungiPartitaStatistiche extends StatefulWidget {
  const AggiungiPartitaStatistiche({Key? key}) : super(key: key);

  @override
  _AggiungiPartitaStatisticheState createState() => _AggiungiPartitaStatisticheState();
}

class _AggiungiPartitaStatisticheState extends State<AggiungiPartitaStatistiche> {
  final _formKey = GlobalKey<FormState>();

  final _avversarioController = TextEditingController();
  final _gameVintiController = TextEditingController();
  final _gamePersiController = TextEditingController();
  final _setVintiController = TextEditingController();
  final _setPersiController = TextEditingController();


  DateTime _dataPartita = DateTime.now();

  Future<void> _selezionaData(BuildContext context) async {
    final DateTime? dataSelezionata = await showDatePicker(
      context: context,
      initialDate: _dataPartita,
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );

    if (dataSelezionata != null && dataSelezionata != _dataPartita) {
      setState(() {
        _dataPartita = dataSelezionata;
      });
    }
  }


  @override
  void dispose() {
    _avversarioController.dispose();
    _gameVintiController.dispose();
    _gamePersiController.dispose();
    _setVintiController.dispose();
    _setPersiController.dispose();
    super.dispose();
  }

  void _salvaPartita() {
    if (_formKey.currentState!.validate()) {
      final String avversario = _avversarioController.text;
      final int gameVinti = int.tryParse(_gameVintiController.text) ?? 0;
      final int gamePersi = int.tryParse(_gamePersiController.text) ?? 0;
      final int setVinti = int.tryParse(_setVintiController.text) ?? 0;
      final int setPersi = int.tryParse(_setPersiController.text) ?? 0;

      final bool isVittoria = setVinti > setPersi;

      final nuovaPartita = Partita(
        avversario: avversario,
        gameVinti: gameVinti,
        gamePersi: gamePersi,
        setVinti: setVinti,
        setPersi: setPersi,
        isVittoria: isVittoria,
        data: _dataPartita,
      );
      Navigator.pop(context, nuovaPartita);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate("Aggiungi Nuova Partita")),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _avversarioController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.translate("Nome Avversario")),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.translate("Inserisci il nome dell'avversario");
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _gameVintiController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.translate("Game Vinti")),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.translate("Inserisci i game vinti");
                  }
                  if (int.tryParse(value) == null) {
                    return AppLocalizations.of(context)!.translate("Inserisci un numero valido");
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _gamePersiController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.translate("Game Persi")),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.translate("Inserisci i game persi");
                  }
                  if (int.tryParse(value) == null) {
                    return AppLocalizations.of(context)!.translate("Inserisci un numero valido");
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _setVintiController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.translate("Set Vinti")),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return AppLocalizations.of(context)!.translate("Inserisci i set vinti");
                  if (int.tryParse(value) == null) return AppLocalizations.of(context)!.translate("Inserisci un numero valido");
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _setPersiController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.translate("Set Persi")),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return AppLocalizations.of(context)!.translate("Inserisci i set persi");
                  if (int.tryParse(value) == null) return AppLocalizations.of(context)!.translate("Inserisci un numero valido");
                  return null;
                },
              ),

              ListTile(
                title: Text(AppLocalizations.of(context)!.translate("Data della Partita")),
                subtitle: Text(DateFormat('dd MMMM yyyy').format(_dataPartita)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selezionaData(context),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _salvaPartita,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(AppLocalizations.of(context)!.translate("Salva Partita")),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}