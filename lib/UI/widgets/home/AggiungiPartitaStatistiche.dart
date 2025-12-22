import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import '../../../model/objects/PartitaModel.dart';
import '../../../model/objects/PrenotazioneModel.dart';
import '../../../services/statistiche_service.dart';
import 'SetScoreList.dart';
import '../CustomSnackBar.dart';

class AggiungiPartitaStatistiche extends StatefulWidget {
  final PrenotazioneModel? prenotazione;
  final bool isSfida;
  final String? nomeAvversarioFisso;

  const AggiungiPartitaStatistiche({
    Key? key,
    this.prenotazione,
    this.isSfida = false,
    this.nomeAvversarioFisso,
  }) : super(key: key);

  @override
  _AggiungiPartitaStatisticheState createState() => _AggiungiPartitaStatisticheState();
}

class _AggiungiPartitaStatisticheState extends State<AggiungiPartitaStatistiche> {
  final _formKey = GlobalKey<FormState>();
  final _avversarioController = TextEditingController();
  final List<SetInputControllers> listaSetController = [];
  DateTime _dataPartita = DateTime.now();
  late final TennisScoreService _service;
  bool _isSaving = false;

  //metodo per aggiungere una nuova riga di set
  void _addSet() {
    setState(() {
      listaSetController.add(SetInputControllers());
    });
  }
  //metodo per rimuovere una riga di set
  void _removeSet(int index) {
    if (listaSetController.length > 1) {
      setState(() {
        listaSetController.removeAt(index);
      });
    }
  }
  @override
  void initState() {
    super.initState();
    _service = TennisScoreService();
    _addSet();
    // Se c'è una prenotazione, preimposta la data
    if (widget.prenotazione != null) {
      _dataPartita = widget.prenotazione!.data;
    }
    // Se è una sfida, preimposta il nome dell'avversario
    if (widget.isSfida && widget.nomeAvversarioFisso != null) {
      _avversarioController.text = widget.nomeAvversarioFisso!;
    }
  }

  Future<void> _selezionaData(BuildContext context) async {
    if (widget.prenotazione != null) {(
        CustomSnackBar.showError(context,backgroundColor: Colors.red,
            AppLocalizations.of(context)!.translate("La data è legata alla prenotazione e non può essere modificata"
            )));
      return;
    }
    final DateTime? dataSelezionata = await showDatePicker(
      context: context,
      initialDate: _dataPartita,
      firstDate: DateTime(2020),
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
    for (var controller in listaSetController) {
      controller.me.dispose();
      controller.opponent.dispose();
    }
    super.dispose();
  }
  // Metodo per costruire la lista dei set
  List<SetScore> _buildSetScores() {
    return listaSetController.where( (set) => set.me.text.isNotEmpty || set.opponent.text.isNotEmpty).map(
            (set) => SetScore(int.tryParse(set.me.text) ?? 0, int.tryParse(set.opponent.text) ?? 0,))
        .toList();
  }
  Future<void> _salvaPartita() async {
    if (!_formKey.currentState!.validate())
      return;
    setState((){
      _isSaving = true;
    });
    try {
      final avversario = _avversarioController.text.trim().isEmpty ? AppLocalizations.of(context)!.translate("Avversario") : _avversarioController.text.trim();
      final sets = _buildSetScores();
      // Validazione della partita, se non va bene il service tirerà una exception che verrà catturata per mostraare una snackbar
      final partita = _service.validaPartita(
        avversario: avversario,
        data: _dataPartita,
        sets: sets,
      );
      await _service.save(partita, widget.prenotazione);
      // Torna indietro con la partita salvata se non ci sono errori
      if (mounted) Navigator.pop(context, partita);
    } catch (e) {
      CustomSnackBar.showError(
        context,
        backgroundColor: Colors.red,
        AppLocalizations.of(context)!.translate(e.toString()),
      );
    } finally {
      if (mounted)
        setState(() {
        _isSaving = false;
        });
    }
  }
  // Metodo per costruire il campo data
  @override
  Widget build(BuildContext context) {
    final dataFormattata = DateFormat.yMMMMd(Localizations.localeOf(context).toString()).format(_dataPartita);
    final primaryColor = Theme.of(context).colorScheme.primary;

    bool isDateLocked = widget.prenotazione != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate("Aggiungi nuova partita")),
      ),

      body: _isSaving ? const Center(child: CircularProgressIndicator()) :

      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // box con il campo se è una prenotazione fatta sull'app
              if (widget.prenotazione != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(22)),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "${widget.prenotazione!.nomeStruttura} - ${widget.prenotazione!.campo}",
                          style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                        ),),],),
                ),
              TextFormField(
                controller: _avversarioController,
                readOnly: widget.isSfida,
                style: widget.isSfida ? const TextStyle(color: Colors.grey) : null,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.translate("Nome avversario"),
                  prefixIcon: const Icon(Icons.person_outline, size: 20, color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(22),borderSide: BorderSide.none),
                  suffixIcon: widget.isSfida ? const Icon(Icons.lock, size: 20, color: Colors.grey) : null,
                  filled: true,
                  fillColor: Colors.grey.withValues(alpha: 0.1),
                ),
                validator: (value) {
                  // Se è sfida, il nome è obbligatorio
                  if (widget.isSfida && (value == null || value.isEmpty)) {
                    return AppLocalizations.of(context)!.translate("Inserisci il nome dell'avversario");
                  }
                  // Se non è sfida, è opzionale
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.translate("Punteggio"),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _addSet,
                    icon: const Icon(Icons.add),
                    label: Text(AppLocalizations.of(context)!.translate("Set")),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  )
                ],
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    const SizedBox(width: 40),
                    Expanded(child: Center(child: Text(AppLocalizations.of(context)!.translate("Io"), style: const TextStyle(fontWeight: FontWeight.bold)))),
                    Expanded(child: Center(child: Text(AppLocalizations.of(context)!.translate("Avversario"), style: const TextStyle(fontWeight: FontWeight.bold)))),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              const Divider(),

              SetScoreList(controllers: listaSetController, onAdd: _addSet, onRemove: _removeSet,),

              const SizedBox(height: 12),

              //Data
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(AppLocalizations.of(context)!.translate("Data della partita"), style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(dataFormattata, style: TextStyle(fontSize: 16, color: isDateLocked ? Colors.grey : null)),
                // lock icon se la data è bloccata
                trailing: isDateLocked
                    ? const Icon(Icons.lock, color: Colors.grey)
                    : Icon(Icons.calendar_today, color: primaryColor),
                onTap: () => _selezionaData(context),
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: _isSaving ? null : _salvaPartita,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  elevation: 2,
                ),
                child: Text(
                  _isSaving ? AppLocalizations.of(context)!.translate("Salvataggio...") : AppLocalizations.of(context)!.translate("Salva risultato"),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
            ],),),),);
  }
}