import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matchup/UI/widgets/CustomSnackBar.dart';
import '../popup/NuovaChat.dart';

class CreaSfida extends StatefulWidget {
  const CreaSfida({Key? key}) : super(key: key);

  @override
  State<CreaSfida> createState() => _CreaSfidaState();
}

class _CreaSfidaState extends State<CreaSfida> {
  final _formKey = GlobalKey<FormState>();

  // Controller
  final _strutturaController = TextEditingController();
  final _avversarioController = TextEditingController();

  // Variabile per salvare l'ID dell'utente selezionato dal popup
  String? _opponentIdSelezionato;

  // Variabili Stato
  DateTime _dataSfida = DateTime.now();
  TimeOfDay _oraSfida = TimeOfDay.now();
  String _livelloSelezionato = 'Amatoriale';
  final List<String> _livelli = ['Principiante', 'Amatoriale', 'Intermedio', 'Avanzato', 'Esperto'];

  // 0 = Pubblica, 1 = Diretta
  int _modalitaSfida = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _strutturaController.dispose();
    _avversarioController.dispose();
    super.dispose();
  }

  Future<void> _selezionaData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataSfida,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dataSfida = picked);
  }

  Future<void> _selezionaOra(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _oraSfida,
    );
    if (picked != null) setState(() => _oraSfida = picked);
  }

  Future<bool> _verificaEsistenzaUtente(String usernameCercato) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: usernameCercato)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _opponentIdSelezionato = querySnapshot.docs.first.id;
      }
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print("Errore verifica utente: $e");
      return false;
    }
  }

  // SALVATAGGIO
  Future<void> _salvaSfida() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      CustomSnackBar.show(context, "Devi essere loggato.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_modalitaSfida == 1) {
        String nomeAvversario = _avversarioController.text.trim();


        if (_opponentIdSelezionato == null) {
          bool esiste = await _verificaEsistenzaUtente(nomeAvversario);
          if (!esiste) {
            throw Exception("L'utente '$nomeAvversario' non esiste.");
          }
        }
      }

      //Recupero dati sfidante
      String myName = "Giocatore";
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        myName = data['username'] ?? data['userName'] ?? data['nome'] ?? "Giocatore";

        // Controllo anti auto-sfida
        if (_modalitaSfida == 1 && (_opponentIdSelezionato == user.uid || _avversarioController.text.trim() == myName)) {
          throw Exception("Non puoi sfidare te stesso!");
        }
      }

      // Formattazione ora
      final localizations = MaterialLocalizations.of(context);
      String oraFormattata = localizations.formatTimeOfDay(_oraSfida, alwaysUse24HourFormat: true);

      //dati
      Map<String, dynamic> sfidaData = {
        'challengerId': user.uid,
        'challengerName': myName,
        'nomeStruttura': _strutturaController.text.trim(),
        'indirizzo': '',
        'data': Timestamp.fromDate(_dataSfida),
        'ora': oraFormattata,
        'livello': _livelloSelezionato,
        'stato': 'aperta',
        'prenotazioneId': null,
        'modalita': _modalitaSfida == 0 ? 'pubblica' : 'diretta',

        // DATI AVVERSARIO
        'opponentName': (_modalitaSfida == 1) ? _avversarioController.text.trim() : null,
        'opponentId': (_modalitaSfida == 1) ? _opponentIdSelezionato : null, // Salviamo l'ID!
      };

      // scrittura su Firebase
      await FirebaseFirestore.instance.collection('sfide').add(sfidaData);

      if (mounted) {
        CustomSnackBar.show(context, "Sfida creata con successo!");
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) CustomSnackBar.show(context, "Errore: ${e.toString().replaceAll("Exception: ", "")}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Crea Nuova Sfida')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // SELETTORE MODALITÀ
              Text("Che tipo di sfida vuoi creare?", style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<int>(
                      title: const Text("Pubblica"),
                      subtitle: const Text("Aperta a tutti"),
                      value: 0,
                      groupValue: _modalitaSfida,
                      contentPadding: EdgeInsets.zero,
                      activeColor: primaryColor,
                      onChanged: (val) => setState(() => _modalitaSfida = val!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<int>(
                      title: const Text("Diretta"),
                      subtitle: const Text("Scegli utente"),
                      value: 1,
                      groupValue: _modalitaSfida,
                      contentPadding: EdgeInsets.zero,
                      activeColor: primaryColor,
                      onChanged: (val) => setState(() => _modalitaSfida = val!),
                    ),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),

              // CAMPO AVVERSARIO
              if (_modalitaSfida == 1) ...[
                TextFormField(
                  controller: _avversarioController,
                  readOnly: true, // Blocca la tastiera per usare il popup!!!
                  decoration: const InputDecoration(
                      labelText: 'Username Avversario',
                      hintText: 'Tocca per scegliere...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_search),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                      helperText: "Deve corrispondere a un utente registrato"
                  ),
                  validator: (value) {
                    if (_modalitaSfida == 1 && (value == null || value.isEmpty)) {
                      return 'Seleziona un avversario';
                    }
                    return null;
                  },
                  onTap: () async {
                    final selectedUser = await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => const NuovaChatSfidaPopup(mode: 0),
                    );
                    if (selectedUser != null && selectedUser is Map<String, dynamic>) {
                      setState(() {
                        _avversarioController.text = selectedUser['username'] ?? selectedUser['displayName'] ?? "Giocatore";
                        _opponentIdSelezionato = selectedUser['uid'];
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Campo struttura
              TextFormField(
                controller: _strutturaController,
                decoration: const InputDecoration(
                  labelText: 'Presso quale struttura?',
                  hintText: 'Es. Tennis Club Napoli',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.stadium),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Inserisci struttura' : null,
              ),
              const SizedBox(height: 16),

              // Livello
              DropdownButtonFormField<String>(
                initialValue: _livelloSelezionato,
                decoration: const InputDecoration(
                  labelText: 'Livello Richiesto',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.signal_cellular_alt),
                ),
                items: _livelli.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                onChanged: (val) => setState(() => _livelloSelezionato = val!),
              ),
              const SizedBox(height: 16),

              // Data e ora
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selezionaData(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Data',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(DateFormat('dd/MM/yyyy').format(_dataSfida)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selezionaOra(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Ora',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(_oraSfida.format(context)),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // BOTTONE
              ElevatedButton(
                onPressed: _salvaSfida,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  _modalitaSfida == 0 ? 'Lancia Sfida Pubblica' : 'Invia Sfida',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}