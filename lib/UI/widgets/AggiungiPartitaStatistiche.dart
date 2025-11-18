import 'package:flutter/material.dart';
import 'package:matchup/UI/widgets/StoricoPartite.dart';
import 'package:intl/intl.dart';

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
        title: const Text('Aggiungi Nuova Partita'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _avversarioController,
                decoration: const InputDecoration(labelText: 'Nome Avversario'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci il nome dell\'avversario';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _gameVintiController,
                decoration: const InputDecoration(labelText: 'Game Vinti'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci i game vinti';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Inserisci un numero valido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _gamePersiController,
                decoration: const InputDecoration(labelText: 'Game Persi'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci i game persi';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Inserisci un numero valido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _setVintiController,
                decoration: const InputDecoration(labelText: 'Set Vinti'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Inserisci i set vinti';
                  if (int.tryParse(value) == null) return 'Inserisci un numero valido';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _setPersiController,
                decoration: const InputDecoration(labelText: 'Set Persi'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Inserisci i set persi';
                  if (int.tryParse(value) == null) return 'Inserisci un numero valido';
                  return null;
                },
              ),

              ListTile(
                title: const Text('Data della Partita'),
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
                child: const Text('Salva Partita'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}