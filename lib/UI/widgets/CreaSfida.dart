import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:matchup/UI/widgets/SfideDisponibili.dart';

class CreaSfida extends StatefulWidget {
  const CreaSfida({Key? key}) : super(key: key);

  @override
  State<CreaSfida> createState() => _CreaSfidaState();
}

class _CreaSfidaState extends State<CreaSfida> {
  final _formKey = GlobalKey<FormState>();

  final _titoloController = TextEditingController();
  final _avversarioController = TextEditingController();
  DateTime _dataSfida = DateTime.now();

  @override
  void dispose() {
    _titoloController.dispose();
    _avversarioController.dispose();
    super.dispose();
  }

  Future<void> _selezionaData(BuildContext context) async {
    final DateTime? dataSelezionata = await showDatePicker(
      context: context,
      initialDate: _dataSfida,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (dataSelezionata != null && dataSelezionata != _dataSfida) {
      setState(() {
        _dataSfida = dataSelezionata;
      });
    }
  }

  void _salvaSfida() {
    if (_formKey.currentState!.validate()) {
      // Creiamo l'oggetto. Assicurati che SfidaModel sia importato correttamente.
      final nuovaSfida = SfidaModel(
        title: _titoloController.text,
        opponent: _avversarioController.text,
      );

      // Restituiamo l'oggetto al widget precedente
      Navigator.of(context).pop(nuovaSfida);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crea Nuova Sfida')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titoloController,
                decoration: const InputDecoration(
                  labelText: 'Titolo Sfida (es. Partita Singola)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Inserisci titolo' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _avversarioController,
                decoration: const InputDecoration(
                  labelText: 'Nome Avversario',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Inserisci avversario' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Data della Sfida'),
                subtitle: Text(
                  DateFormat('dd MMMM yyyy').format(_dataSfida),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selezionaData(context),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _salvaSfida,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Invia Sfida'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}