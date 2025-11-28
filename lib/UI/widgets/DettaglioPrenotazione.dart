import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matchup/model/CampoModel.dart';
import 'package:matchup/UI/widgets/CustomSnackBar.dart';
import 'package:matchup/UI/widgets/HorizontalWeekCalendar.dart';

class DettaglioPrenotazione extends StatefulWidget {
  final CampoModel campo;

  const DettaglioPrenotazione({Key? key, required this.campo}) : super(key: key);

  @override
  State<DettaglioPrenotazione> createState() => _DettaglioPrenotazioneState();
}

class _DettaglioPrenotazioneState extends State<DettaglioPrenotazione> {
  final ScrollController _scrollController = ScrollController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  bool _isLoadingPrenotazioni = false;

  // Mappa per tenere traccia dei minuti occupati per ogni sotto-campo
  Map<String, Set<int>> _orariOccupatiPerCampo = {};

  final List<String> _allDailySlots = [
    "09:00", "09:30", "10:00", "10:30", "11:00", "11:30",
    "16:30", "17:00", "17:30", "18:00", "18:30", "19:00",
    "19:30", "20:00", "20:30", "21:00", "21:30", "22:00"
  ];

  @override
  void initState() {
    super.initState();
    _caricaPrenotazioni(); // Carica le prenotazioni all'avvio
  }

  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  //LOGICA GESTIONE ORARI
  int _toMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  // Scarica le prenotazioni da Firebase per la data selezionata
  Future<void> _caricaPrenotazioni() async {
    setState(() {
      _isLoadingPrenotazioni = true;
      _orariOccupatiPerCampo.clear(); // Pulisce i dati vecchi
    });

    try {
      String dataString = DateFormat('yyyy-MM-dd').format(_selectedDate);

      // Query: Dammi tutte le prenotazioni di QUESTA struttura in QUESTA data
      final snapshot = await FirebaseFirestore.instance
          .collection('prenotazioni')
          .where('campoId', isEqualTo: widget.campo.id)
          .where('dataString', isEqualTo: dataString)
          .get();

      Map<String, Set<int>> tempMap = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        String nomeSottoCampo = data['nomeSottoCampo'] ?? '';
        String oraInizio = data['oraInizio'] ?? '00:00';
        int durata = data['durataMinuti'] ?? 0;

        if (nomeSottoCampo.isNotEmpty) {
          if (!tempMap.containsKey(nomeSottoCampo)) {
            tempMap[nomeSottoCampo] = {};
          }

          // Calcola tutti gli slot da 30 min occupati da questa prenotazione
          int startMin = _toMinutes(oraInizio);
          int slotsCoperti = durata ~/ 30;

          for (int i = 0; i < slotsCoperti; i++) {
            tempMap[nomeSottoCampo]!.add(startMin + (i * 30));
          }
        }
      }

      setState(() {
        _orariOccupatiPerCampo = tempMap;
        _isLoadingPrenotazioni = false;
      });

    } catch (e) {
      print("Errore caricamento prenotazioni: $e");
      setState(() => _isLoadingPrenotazioni = false);
    }
  }

  // Verifica se uno slot specifico è libero per un certo campo e durata
  bool _isTimeSlotAvailable(String nomeSottoCampo, String startTime, int durataMinuti) {
    // Se non ci sono prenotazioni per questo campo, è libero
    if (!_orariOccupatiPerCampo.containsKey(nomeSottoCampo)) return true;

    Set<int> minutiOccupati = _orariOccupatiPerCampo[nomeSottoCampo]!;
    int startMin = _toMinutes(startTime);
    int slotsNecessari = durataMinuti ~/ 30;

    // Controllo se ogni slot di 30 minuti necessario è libero
    for (int i = 0; i < slotsNecessari; i++) {
      int checkTime = startMin + (i * 30);
      if (minutiOccupati.contains(checkTime)) {
        return false;
      }
    }
    return true;
  }

  List<String> _getSelectableSlots() {
    return _allDailySlots;
  }

  List<int> _getAvailableDurations() {
    return [60, 90, 120];
  }

  String _formatDurationText(int minutes) {
    if (minutes == 60) return "60 min";
    if (minutes == 90) return "90 min";
    if (minutes == 120) return "2 ore";
    return "$minutes min";
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  //LOGICA PRENOTAZIONE E SALVATAGGIO
  Future<void> _confermaPrenotazione(String nomeSottoCampo, int durataMinuti) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      CustomSnackBar.show(context, "Devi essere loggato per prenotare!");
      return;
    }

    double ore = durataMinuti / 60.0;
    double totale = widget.campo.prezzoOrario * ore;

    final String currentLocale = Localizations.localeOf(context).languageCode;
    String dataFormattata = DateFormat.yMd(currentLocale).format(_selectedDate);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Conferma Prenotazione"),
        content: Text(
            "Struttura: ${widget.campo.nome}\n"
                "Campo: $nomeSottoCampo\n"
                "Data: $dataFormattata\n"
                "Ora: $_selectedTimeSlot\n"
                "Durata: ${_formatDurationText(durataMinuti)}\n\n"
                "Totale: €${totale.toStringAsFixed(2)}"
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Annulla")
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (c) => const Center(child: CircularProgressIndicator())
              );

              try {
                //Recupero nome
                String nomeReale = "Utente";
                try {
                  DocumentSnapshot userDoc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .get();
                  if (userDoc.exists) {
                    final data = userDoc.data() as Map<String, dynamic>;
                    nomeReale = data['username'] ?? data['userName'] ?? data['nome'] ?? "Utente";
                  }
                } catch (_) {}

                //Salvataggio
                await FirebaseFirestore.instance.collection('prenotazioni').add({
                  'userId': user.uid,
                  'userName': nomeReale,
                  'campoId': widget.campo.id,
                  'nomeStruttura': widget.campo.nome,
                  'nomeSottoCampo': nomeSottoCampo,
                  'indirizzo': widget.campo.indirizzo,
                  'data': Timestamp.fromDate(_selectedDate),
                  'dataString': DateFormat('yyyy-MM-dd').format(_selectedDate),
                  'oraInizio': _selectedTimeSlot,
                  'durataMinuti': durataMinuti,
                  'prezzoTotale': totale,
                  'timestampCreazione': FieldValue.serverTimestamp(),
                });

                // Ricarica le disponibilità per aggiornare la UI
                await _caricaPrenotazioni();

                if (mounted) Navigator.pop(context); // loading
                if (mounted) Navigator.pop(context); // pagina

                CustomSnackBar.show(context, "Prenotazione confermata per $nomeReale!");

              } catch (e) {
                if (mounted) Navigator.pop(context);
                CustomSnackBar.show(context, "Errore durante la prenotazione.");
              }
            },
            child: const Text("Conferma"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> selectableSlots = _getSelectableSlots();
    List<int> availableDurations = _getAvailableDurations();
    final List<String> campiAttuali = widget.campo.campiDisponibili;

    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color secondaryColor = Theme.of(context).colorScheme.secondary;
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.campo.nome),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(Icons.sports_tennis, size: 80, color: primaryColor),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.campo.nome,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: onSurfaceColor),
            ),
            Text(
              "${widget.campo.indirizzo}, ${widget.campo.citta}",
              style: TextStyle(color: onSurfaceColor.withValues(alpha: 0.6), fontSize: 16),
            ),
            const Divider(height: 30),

            HorizontalWeekCalendar(
              selectedDate: _selectedDate,
              allowPastDates: false,
              onDateChanged: (newDate) {
                setState(() {
                  _selectedDate = newDate;
                  _selectedTimeSlot = null;
                });
                _caricaPrenotazioni(); // Ricarica quando cambi giorno
              },
            ),
            const SizedBox(height: 25),

            if (_isLoadingPrenotazioni)
              const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ))
            else ...[
              Text("Seleziona Orario", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onSurfaceColor)),
              const SizedBox(height: 10),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 2.0,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: selectableSlots.length,
                itemBuilder: (context, index) {
                  final time = selectableSlots[index];
                  final isSelected = _selectedTimeSlot == time;
                  Color slotBgColor = isSelected ? primaryColor : (isDarkMode ? secondaryColor : Colors.grey.shade200);
                  Color slotTextColor = isSelected ? Colors.white : Colors.black87;

                  return InkWell(
                    onTap: () {
                      setState(() => _selectedTimeSlot = time);
                      _scrollToBottom();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: slotBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(time, style: TextStyle(color: slotTextColor, fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              if (_selectedTimeSlot != null) ...[
                const Divider(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 20, color: onSurfaceColor),
                    const SizedBox(width: 8),
                    Text(
                      widget.campo.nome.toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: onSurfaceColor.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (campiAttuali.isEmpty)
                  const Text("Nessun campo disponibile.")
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: campiAttuali.length,
                    itemBuilder: (ctx, index) {
                      final nomeSottoCampo = campiAttuali[index];

                      // Controlliamo se almeno la durata minima (60 min) è disponibile
                      bool isBaseAvailable = _isTimeSlotAvailable(nomeSottoCampo, _selectedTimeSlot!, 60);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.arrow_right, size: 24, color: primaryColor),
                                Text(nomeSottoCampo, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: onSurfaceColor)),
                              ],
                            ),
                          ),

                          // SE IL CAMPO È OCCUPATO NELL'ORA DI INIZIO
                          if (!isBaseAvailable)
                            Padding(
                              padding: const EdgeInsets.only(left: 10, bottom: 10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red.withValues(alpha: 0.5))
                                ),
                                child: const Text("Già prenotato in questo orario", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              ),
                            )
                          else
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: availableDurations.map((durata) {
                                  // Controllo se QUESTA specifica durata è disponibile
                                  bool isDurationAvailable = _isTimeSlotAvailable(nomeSottoCampo, _selectedTimeSlot!, durata);

                                  if (!isDurationAvailable) return const SizedBox.shrink(); // Nasconde durata se si sovrappone

                                  double prezzo = widget.campo.prezzoOrario * (durata / 60.0);
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: InkWell(
                                      onTap: () => _confermaPrenotazione(nomeSottoCampo, durata),
                                      child: Container(
                                        width: 110,
                                        height: 75,
                                        decoration: BoxDecoration(
                                          color: secondaryColor,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "${prezzo.toStringAsFixed(2)} €",
                                              style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 20, fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              _formatDurationText(durata),
                                              style: TextStyle(color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.8), fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          const SizedBox(height: 20),
                        ],
                      );
                    },
                  ),
                const SizedBox(height: 80),
              ],
            ],
          ],
        ),
      ),
    );
  }
}