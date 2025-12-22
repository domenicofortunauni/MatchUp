import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matchup/UI/widgets/dialogs/confermaPrenotazioneDialog.dart';
import 'package:matchup/model/objects/CampoModel.dart';
import 'package:matchup/UI/widgets/CustomSnackBar.dart';
import 'package:matchup/UI/widgets/HorizontalWeekCalendar.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import 'package:matchup/services/notification_service.dart';

class PrenotaCampo extends StatefulWidget {
  final CampoModel campo;
  final bool tipoPrenotazione;

   PrenotaCampo({Key? key, required this.campo,required this.tipoPrenotazione}) : super(key: key);

  @override
  State<PrenotaCampo> createState() => _PrenotaCampoState();
}

class _PrenotaCampoState extends State<PrenotaCampo> {
  final ScrollController _scrollController = ScrollController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  bool _isLoadingPrenotazioni = false;

  Map<String, Set<int>> _orariOccupatiPerCampo = {};

  final List<String> _allDailySlots = [
    "09:00", "09:30", "10:00", "10:30", "11:00", "15:00",
    "15:30", "16:00",
    "16:30", "17:00", "17:30", "18:00", "18:30", "19:00",
    "19:30", "20:00", "20:30", "21:00", "21:30", "22:00"
  ];

  @override
  void initState() {
    super.initState();
    _caricaPrenotazioni();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  // logica orari
  int _toMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
  String _formatDurationText(int minutes) {
    if (minutes == 60) return AppLocalizations.of(context)!.translate("1 ora");
    if (minutes == 90) return AppLocalizations.of(context)!.translate("1 ora e 30 min");
    if (minutes == 120) return AppLocalizations.of(context)!.translate("2 ore");
    return "$minutes ${AppLocalizations.of(context)!.translate("min")}";
  }
  // Controlla se un orario è già passato rispetto ad adesso
  bool _isSlotPast(String timeSlot) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    if (selectedDay.isAfter(today)) return false;
    if (selectedDay.isBefore(today)) return true;
    final parts = timeSlot.split(':');
    final slotHour = int.parse(parts[0]);
    final slotMinute = int.parse(parts[1]);
    final slotDateTime = DateTime(now.year, now.month, now.day, slotHour, slotMinute);
    return slotDateTime.isBefore(now);
  }

  Future<void> _caricaPrenotazioni() async {
    setState(() {
      _isLoadingPrenotazioni = true;
      _orariOccupatiPerCampo.clear();
    });

    try {
      String dataString = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final snapshot = await FirebaseFirestore.instance
          .collection('prenotazioni')
          .where('campoId', isEqualTo: widget.campo.id)
          .where('dataString', isEqualTo: dataString)
          .get();

      Map<String, Set<int>> tempMap = {};

      for (var prenotazione in snapshot.docs) {
        final data = prenotazione.data();
        if (data['stato'] == 'Annullato') continue;
        String nomeSottoCampo = data['nomeSottoCampo'] ?? '';
        String oraInizio = data['oraInizio'] ?? '00:00';
        int durata = data['durataMinuti'] ?? 0;

        if (nomeSottoCampo.isNotEmpty) {
          if (!tempMap.containsKey(nomeSottoCampo)) {
            tempMap[nomeSottoCampo] = {};
          }
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

  bool _isTimeSlotAvailable(String nomeSottoCampo, String startTime, int durataMinuti) {
    if (!_orariOccupatiPerCampo.containsKey(nomeSottoCampo)) return true;

    Set<int> minutiOccupati = _orariOccupatiPerCampo[nomeSottoCampo]!;
    int startMin = _toMinutes(startTime);
    int slotsNecessari = durataMinuti ~/ 30;

    for (int i = 0; i < slotsNecessari; i++) {
      int checkTime = startMin + (i * 30);
      if (minutiOccupati.contains(checkTime)) {
        return false;
      }
    }
    return true;
  }

  List<String> _getSelectableSlots() { return _allDailySlots; }

  List<int> _getAvailableDurations() { return [60, 90, 120];}

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
  Future<void> _confermaPrenotazione(String nomeSottoCampo, int durataMinuti) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      CustomSnackBar.show(context, AppLocalizations.of(context)!.translate("Devi essere loggato per prenotare!"));
      return;
    }
    double ore = durataMinuti / 60.0;
    double totale = widget.campo.prezzoOrario * ore;

    showDialog(
      context: context,
      builder: (_) => confermaPrenotazioneDialog(
        campo: widget.campo,
        nomeSottoCampo: nomeSottoCampo,
        data: _selectedDate,
        ora: _selectedTimeSlot!,
        durataMinuti: durataMinuti,
        totale: totale,
        tipoPrenotazione: widget.tipoPrenotazione,
        onConferma: ({
          required bool isSfida,
          String? modalita,
          String? avversarioUsername,
          String? avversarioUid,
        }) {
          _salvaSuFirebase(
            nomeSottoCampo,
            durataMinuti,
            totale,
            isSfida: isSfida,
            modalita: modalita,
            avversarioUsername: avversarioUsername,
            avversarioUid: avversarioUid,
          );
        },
      ),
    );
  }
  // salvataggio
  Future<void> _salvaSuFirebase(
      String nomeSottoCampo,
      int durataMinuti,
      double totale,
      {required bool isSfida, String? modalita, String? avversarioUsername,
        String? avversarioUid,}
      ) async {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator())
    );

    try {
      String nomeReale = AppLocalizations.of(context)!.translate("Utente");
      String livelloGiocatore = AppLocalizations.of(context)!.translate("Amatoriale");
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          nomeReale = data['username'] ?? data['nome'] ?? AppLocalizations.of(context)!.translate("Utente");
          livelloGiocatore = data['livello'] ?? AppLocalizations.of(context)!.translate("Amatoriale");

          if (isSfida && modalita == 'diretta' && avversarioUid == user.uid) {
            throw Exception(AppLocalizations.of(context)!.translate("Non puoi sfidare te stesso!"));
          }
        }
      } catch (e) {
        if (mounted) Navigator.pop(context);
        CustomSnackBar.show(context, "$e");
        return;
      }

      DocumentReference prenotazioneRef = await FirebaseFirestore.instance.collection('prenotazioni').add({
        'userId': user.uid,
        'username': nomeReale,
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
        'tipo': isSfida ? 'sfida' : 'prenotazione',
        'stato': 'Confermato'
      });

      try {
        if (_selectedTimeSlot != null) {
          final timeParts = _selectedTimeSlot!.split(':');
          final dataPartita = DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );
          final notificationId = prenotazioneRef.id.hashCode.abs();
          await NotificationService().scheduleNotification(
              notificationId,
              AppLocalizations.of(context)!.translate("Hai una partita tra poco!"),
              AppLocalizations.of(context)!.translate("La tua prenotazione al") + " ${widget.campo.nome} "
                  + AppLocalizations.of(context)!.translate("inizia alle") + " $_selectedTimeSlot.",
              dataPartita
          );
        }
      } catch (e) {
      }

      if (isSfida) {
        await FirebaseFirestore.instance.collection('sfide').add({
          'prenotazioneId': prenotazioneRef.id,
          'challengerId': user.uid,
          'challengerName': nomeReale,
          'opponentId': modalita == 'diretta' ? avversarioUid : null,
          'opponentName': modalita == 'diretta' ? avversarioUsername : null,
          'nomeStruttura': widget.campo.nome,
          'campo': nomeSottoCampo,
          'indirizzo': widget.campo.indirizzo,
          'data': Timestamp.fromDate(_selectedDate),
          'ora': _selectedTimeSlot,
          'durataMinuti': durataMinuti,
          'livello': livelloGiocatore,
          'stato': 'aperta',
          'modalita': modalita ?? 'pubblica',
        });
      }

      await _caricaPrenotazioni();
      if (mounted) Navigator.pop(context);
      if (mounted) Navigator.pop(context);

    } catch (e) {
      if (mounted) Navigator.pop(context);
      CustomSnackBar.show(context, "${AppLocalizations.of(context)!.translate("Errore: ")}$e");
    }
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
                child: Icon(Icons.sports_tennis, size: 100, color: primaryColor),
                //si dovrebbero mettere le immagini su fire storage
              ),
            ),
            const SizedBox(height: 20),
            Text(widget.campo.nome,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: onSurfaceColor),
            ),
            Text("${widget.campo.indirizzo}, ${widget.campo.citta}",
              style: TextStyle(color: onSurfaceColor.withValues(alpha: 0.6), fontSize: 16),
            ),
            const Divider(height: 20),

            HorizontalWeekCalendar(
              selectedDate: _selectedDate,
              allowPastDates: false,
              onDateChanged: (newDate) {
                setState(() {
                  _selectedDate = newDate;
                  _selectedTimeSlot = null;
                });
                _caricaPrenotazioni();
              },
            ),
            const SizedBox(height: 15),

            if (_isLoadingPrenotazioni)
              const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ))
            else ...[
              Text(AppLocalizations.of(context)!.translate("Seleziona Orario"), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onSurfaceColor)),
              const SizedBox(height: 20),

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
                  // Controllo se l'orario è passato
                  bool isPast = _isSlotPast(time);
                  final isSelected = _selectedTimeSlot == time;
                  // Se è passato, grigio e non cliccabile
                  Color slotBgColor;
                  if (isPast) {
                    slotBgColor = Colors.grey.shade300;
                  } else if (isSelected) {
                    slotBgColor = primaryColor;
                  } else {
                    slotBgColor = isDarkMode ? secondaryColor : Colors.grey.shade200;
                  }

                  Color slotTextColor = (isPast) ? Colors.grey.shade500 : (isSelected ? Colors.white : Colors.black87);

                  return InkWell(
                    onTap: isPast ? null : () {
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

              const SizedBox(height: 10),

              if (_selectedTimeSlot != null) ...[
                const Divider(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 20, color: onSurfaceColor),
                    const SizedBox(width: 8),
                    Text(widget.campo.nome.toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: onSurfaceColor.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (campiAttuali.isEmpty)
                  Text(AppLocalizations.of(context)!.translate("Nessun campo disponibile."))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: campiAttuali.length,
                    itemBuilder: (ctx, index) {
                      final nomeSottoCampo = campiAttuali[index];
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
                                child: Text(AppLocalizations.of(context)!.translate("Già prenotato in questo orario"), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              ),
                            )
                          else
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: availableDurations.map((durata) {
                                  bool isDurationAvailable = _isTimeSlotAvailable(nomeSottoCampo, _selectedTimeSlot!, durata);
                                  if (!isDurationAvailable) return const SizedBox.shrink();

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