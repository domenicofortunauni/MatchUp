import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../model/objects/PartitaModel.dart';
import '../../../model/objects/PrenotazioneModel.dart';

class AggiungiPartitaStatistiche extends StatefulWidget {
  final Prenotazione? prenotazione;

  const AggiungiPartitaStatistiche({Key? key, this.prenotazione}) : super(key: key);

  @override
  _AggiungiPartitaStatisticheState createState() => _AggiungiPartitaStatisticheState();
}

class _SetInputControllers {
  final TextEditingController me = TextEditingController();
  final TextEditingController opponent = TextEditingController();
}

class _AggiungiPartitaStatisticheState extends State<AggiungiPartitaStatistiche> {
  final _formKey = GlobalKey<FormState>();
  final _avversarioController = TextEditingController();

  final List<_SetInputControllers> _setControllers = [];
  DateTime _dataPartita = DateTime.now();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _addSet();
    if (widget.prenotazione != null) {
      _dataPartita = widget.prenotazione!.data;
    }
  }

  void _addSet() {
    setState(() {
      _setControllers.add(_SetInputControllers());
    });
  }

  void _removeSet(int index) {
    if (_setControllers.length > 1) {
      setState(() {
        _setControllers.removeAt(index);
      });
    }
  }

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
    for (var controller in _setControllers) {
      controller.me.dispose();
      controller.opponent.dispose();
    }
    super.dispose();
  }

  Future<void> _salvaPartita() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      final String avversario = _avversarioController.text;

      int totalGameVinti = 0;
      int totalGamePersi = 0;
      int totalSetVinti = 0;
      int totalSetPersi = 0;

      List<String> punteggioDettagliato = [];

      List<_SetInputControllers> setValidi = _setControllers.where((s) {
        return s.me.text.isNotEmpty || s.opponent.text.isNotEmpty;
      }).toList();

      if (setValidi.length % 2 == 0) {
        _showError(AppLocalizations.of(context)!.translate("Il numero di set giocati deve essere dispari (es. 1, 3, 5)"));
        setState(() => _isSaving = false);
        return;
      }

      for (int i = 0; i < setValidi.length; i++) {
        var set = setValidi[i];
        String meText = set.me.text;
        String oppText = set.opponent.text;

        int myGames = int.tryParse(meText) ?? 0;
        int oppGames = int.tryParse(oppText) ?? 0;

        int maxGames = myGames > oppGames ? myGames : oppGames;
        int minGames = myGames < oppGames ? myGames : oppGames;

        //Logica di validazione del punteggio
        if (maxGames != 6 && maxGames != 7) {
          _showError(
              "${AppLocalizations.of(context)!.translate("Set")} ${i + 1}: ${AppLocalizations.of(context)!.translate("Il vincitore deve avere 6 o 7 game")}"
          );
          setState(() => _isSaving = false);
          return;
        }

        if (maxGames == 7 && (minGames != 5 && minGames != 6)) {
          _showError(
              "${AppLocalizations.of(context)!.translate("Set")} ${i + 1}: ${AppLocalizations.of(context)!.translate("Per vincere a 7, l'avversario deve avere 5 o 6 game")}"
          );
          setState(() => _isSaving = false);
          return;
        }

        if (maxGames == 6 && minGames >= 5) {
          _showError(
              "${AppLocalizations.of(context)!.translate("Set")} ${i + 1}: ${AppLocalizations.of(context)!.translate("Sul 6-5 si continua a giocare")}"
          );
          setState(() => _isSaving = false);
          return;
        }

        totalGameVinti += myGames;
        totalGamePersi += oppGames;

        punteggioDettagliato.add("$myGames-$oppGames");

        if (myGames > oppGames) {
          totalSetVinti++;
        } else if (oppGames > myGames) {
          totalSetPersi++;
        }
      }

      final bool isVittoria = totalSetVinti > totalSetPersi;

      final nuovaPartita = Partita(
        avversario: avversario,
        gameVinti: totalGameVinti,
        gamePersi: totalGamePersi,
        setVinti: totalSetVinti,
        setPersi: totalSetPersi,
        isVittoria: isVittoria,
        data: _dataPartita,
      );

      try {
        final User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final Map<String, dynamic> datiPartita = {
            'userId': user.uid,
            'avversario': avversario,
            'data': Timestamp.fromDate(_dataPartita),
            'gameVinti': totalGameVinti,
            'gamePersi': totalGamePersi,
            'setVinti': totalSetVinti,
            'setPersi': totalSetPersi,
            'isVittoria': isVittoria,
            'punteggioStringa': punteggioDettagliato.join(' '),
            'prenotazioneId': widget.prenotazione?.id,
            'nomeStruttura': widget.prenotazione?.nomeStruttura ?? "",
            'campo': widget.prenotazione?.campo ?? "",
            'timestamp_creazione': FieldValue.serverTimestamp(),
          };
          await FirebaseFirestore.instance.collection('partite').add(datiPartita);

          await FirebaseFirestore.instance.collection('statistiche').add(datiPartita);

          if (mounted) {
            Navigator.pop(context, nuovaPartita);
          }
        } else {
          _showError(AppLocalizations.of(context)!.translate("Utente non loggato"));
        }
      } catch (e) {
        _showError("${AppLocalizations.of(context)!.translate("Errore durante il salvataggio:")} $e");
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate("Aggiungi nuova partita")),
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (widget.prenotazione != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "${widget.prenotazione!.nomeStruttura} - ${widget.prenotazione!.campo}",
                          style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),

              TextFormField(
                controller: _avversarioController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.translate("Nome avversario"),
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.translate("Inserisci il nome dell'avversario");
                  }
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
              const SizedBox(height: 8),

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

              ..._setControllers.asMap().entries.map((entry) {
                int idx = entry.key;
                _SetInputControllers controllers = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Center(
                          child: Text("${idx + 1}°", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: TextFormField(
                              controller: controllers.me,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                isDense: true,
                              ),
                              validator: (val) {
                                if (idx == 0 && (val == null || val.isEmpty)) return AppLocalizations.of(context)!.translate("Obbligatorio!");
                                return null;
                              }
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: TextFormField(
                              controller: controllers.opponent,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                isDense: true,
                              ),
                              validator: (val) {
                                if (idx == 0 && (val == null || val.isEmpty)) return AppLocalizations.of(context)!.translate("Obbligatorio!");
                                return null;
                              }
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: idx > 0
                            ? IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () => _removeSet(idx),
                        )
                            : const SizedBox(),
                      )
                    ],
                  ),
                );
              }).toList(),

              const SizedBox(height: 24),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(AppLocalizations.of(context)!.translate("Data della partita"), style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(DateFormat('dd MMMM yyyy').format(_dataPartita), style: const TextStyle(fontSize: 16)),
                trailing: Icon(Icons.calendar_today, color: primaryColor),
                onTap: () => _selezionaData(context),
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isSaving ? null : _salvaPartita,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: Text(
                  _isSaving
                      ? AppLocalizations.of(context)!.translate("Salvataggio...")
                      : AppLocalizations.of(context)!.translate("Salva risultato"),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}