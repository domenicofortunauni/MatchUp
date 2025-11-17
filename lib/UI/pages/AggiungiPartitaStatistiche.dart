import 'package:flutter/material.dart';
import 'package:matchup/UI/widgets/Statistiche.dart';
import 'package:intl/intl.dart';

class AggiungiPartitaStatistiche extends StatefulWidget {
  const AggiungiPartitaStatistiche({Key? key}) : super(key: key);

  @override
  _AggiungiPartitaStatisticheState createState() => _AggiungiPartitaStatisticheState();
}

class _AggiungiPartitaStatisticheState extends State<AggiungiPartitaStatistiche> {
  final _formKey = GlobalKey<FormState>();
  final _puntiFattiController = TextEditingController();
  final _puntiSubitiController = TextEditingController();
  final _setVintiController = TextEditingController();
  final _setPersiController = TextEditingController();


  DateTime _dataPartita = DateTime.now();
  // Metodo per aprire la selezione della data
  Future<void> _selezionaData(BuildContext context) async {
    final DateTime? dataSelezionata = await showDatePicker(
      context: context,
      initialDate: _dataPartita, // Data iniziale
      firstDate: DateTime(2010), // Data più vecchia selezionabile
      lastDate: DateTime.now(),   // Data più recente (oggi)
    );

    if (dataSelezionata != null && dataSelezionata != _dataPartita) {
      setState(() {
        _dataPartita = dataSelezionata;
      });
    }
  }


  @override
  void dispose() {
    _puntiFattiController.dispose();
    _puntiSubitiController.dispose();
    _setVintiController.dispose();
    _setPersiController.dispose();
    super.dispose();
  }

  void _salvaPartita() {
    if (_formKey.currentState!.validate()) {
      final int puntiFatti = int.tryParse(_puntiFattiController.text) ?? 0;
      final int puntiSubiti = int.tryParse(_puntiSubitiController.text) ?? 0;
      final int setVinti = int.tryParse(_setVintiController.text) ?? 0;
      final int setPersi = int.tryParse(_setPersiController.text) ?? 0;

      final bool isVittoria = setVinti > setPersi;

      final nuovaPartita = Partita(
        puntiFatti: puntiFatti,
        puntiSubiti: puntiSubiti,
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
        title: Text('Aggiungi Nuova Partita'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campo dei punti fatti
              TextFormField(
                controller: _puntiFattiController,
                decoration: InputDecoration(labelText: 'Punti Fatti'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci i punti fatti';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Inserisci un numero valido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Campo dei punti subiti
              TextFormField(
                controller: _puntiSubitiController,
                decoration: InputDecoration(labelText: 'Punti Subiti'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci i punti subiti';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Inserisci un numero valido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Campi dei set vinti e persi
              TextFormField(
                controller: _setVintiController,
                decoration: InputDecoration(labelText: 'Set Vinti'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Inserisci i set vinti';
                  if (int.tryParse(value) == null) return 'Inserisci un numero valido';
                  return null;
                },
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _setPersiController,
                decoration: InputDecoration(labelText: 'Set Persi'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Inserisci i set persi';
                  if (int.tryParse(value) == null) return 'Inserisci un numero valido';
                  return null;
                },
              ),

              // Widget per selezionare la data
              ListTile(
                title: Text('Data della Partita'),
                subtitle: Text(DateFormat('dd MMMM yyyy').format(_dataPartita)),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selezionaData(context),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _salvaPartita,
                child: Text('Salva Partita'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}