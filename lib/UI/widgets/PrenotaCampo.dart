import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matchup/UI/widgets/popup/NuovaChat.dart';
import 'package:matchup/model/objects/CampoModel.dart';
import 'package:matchup/UI/widgets/CustomSnackBar.dart';
import 'package:matchup/UI/widgets/HorizontalWeekCalendar.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import 'package:matchup/services/notification_service.dart';

class PrenotaCampo extends StatefulWidget {
  final CampoModel campo;
  bool tipoPrenotazione;

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
    "09:00", "09:30", "10:00", "10:30", "11:00", "11:30",
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

  // --- LOGICHE ORARI ---
  int _toMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  String _formatDurationText(int minutes) {
    if (minutes == 60) return AppLocalizations.of(context)!.translate("1 ora");
    if (minutes == 90) return AppLocalizations.of(context)!.translate("1 ora e 30 min");
    if (minutes == 120) return AppLocalizations.of(context)!.translate("2 ore");
    // Per i minuti generici, traduciamo solo l'etichetta "min"
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

      for (var doc in snapshot.docs) {
        final data = doc.data();
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

  List<String> _getSelectableSlots() {
    return _allDailySlots;
  }

  List<int> _getAvailableDurations() {
    return [60, 90, 120];
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

  Future<bool> _checkUserExists(String username) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }


  Future<void> _confermaPrenotazione(String nomeSottoCampo, int durataMinuti) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      CustomSnackBar.show(context, AppLocalizations.of(context)!.translate("Devi essere loggato per prenotare!"));
      return;
    }

    double ore = durataMinuti / 60.0;
    double totale = widget.campo.prezzoOrario * ore;

    final String currentLocale = Localizations.localeOf(context).languageCode;
    String dataFormattata = DateFormat.yMd(currentLocale).format(_selectedDate);

    // Variabili stato dialog
    int modalitaScelta = 0;
    String avversarioSelezionato = "";
    TextEditingController controller = TextEditingController();
    bool mostraErroreAvversario = false;
    bool abilitaSfida = widget.tipoPrenotazione;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                title: Text(AppLocalizations.of(context)!.translate("Completa Prenotazione")),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${AppLocalizations.of(context)!.translate("Struttura: ")}${widget.campo.nome}"),
                      Text("${AppLocalizations.of(context)!.translate("Campo: ")}$nomeSottoCampo"),
                      Text("${AppLocalizations.of(context)!.translate("Data: ")}$dataFormattata - ${AppLocalizations.of(context)!.translate("Ore: ")}$_selectedTimeSlot"),
                      Text("${AppLocalizations.of(context)!.translate("Totale: ")}€${totale.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),

                      const Divider(height: 30),

                      SwitchListTile(
                        title: Text(AppLocalizations.of(context)!.translate("Vuoi lanciare una sfida?"), style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(AppLocalizations.of(context)!.translate("Crea una partita pubblica o sfida un amico")),
                        activeThumbColor: Theme.of(context).colorScheme.primary,
                        contentPadding: EdgeInsets.zero,
                        value: abilitaSfida && widget.tipoPrenotazione ? true : abilitaSfida,
                        onChanged: abilitaSfida && widget.tipoPrenotazione
                            ? null
                            : (val) => setStateDialog(() => abilitaSfida = val),

                      ),

                      if (abilitaSfida) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2))
                          ),
                          child: Column(
                            children: [
                              RadioGroup<int>(
                                groupValue: modalitaScelta,
                                onChanged: (val) {
                                  if (val != null) {
                                    setStateDialog(() => modalitaScelta = val);
                                  }
                                },
                                child: Column(
                                  children: [
                                    RadioListTile<int>(
                                      title: Text(AppLocalizations.of(context)!.translate("Pubblica")),
                                      subtitle: Text(AppLocalizations.of(context)!.translate("Aperta a tutti")),
                                      value: 0,
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                      activeColor: Theme.of(context).colorScheme.primary,
                                    ),
                                    RadioListTile<int>(
                                      title: Text(AppLocalizations.of(context)!.translate("Diretta")),
                                      subtitle: Text(AppLocalizations.of(context)!.translate("Scegli avversario")),
                                      value: 1,
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                      activeColor: Theme.of(context).colorScheme.primary,
                                    ),
                                  ],
                                ),
                              ),

                              if (modalitaScelta == 1) ...[
                                const SizedBox(height: 10),
                                TextField(
                                  controller: controller,
                                  readOnly: true,
                                  onTap: () async {
                                    final selectedUser = await showModalBottomSheet<Map<String, dynamic>>(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (_) => const NuovaChatSfidaPopup(mode: 0),
                                    );
                                    if (selectedUser != null) {
                                      setStateDialog(() {
                                      controller.text = selectedUser['displayName'] ?? selectedUser['username'] ?? "";
                                      avversarioSelezionato = controller.text;
                                      mostraErroreAvversario = false;
                                        }
                                      );
                                    }
                                    },
                                  decoration: InputDecoration(
                                    labelText: AppLocalizations.of(context)!.translate("Cerca Username Avversario"),
                                    border:  OutlineInputBorder(borderRadius: BorderRadius.circular(22)),
                                    prefixIcon: const Icon(Icons.person_search),
                                  ),
                                )
                              ],
                            ],
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(AppLocalizations.of(context)!.translate("Annulla")),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: abilitaSfida ? Theme.of(context).primaryColor : Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      if (abilitaSfida && modalitaScelta == 1 && avversarioSelezionato.trim().isEmpty) {
                        setStateDialog(() => mostraErroreAvversario = true);
                        return;
                      }

                      Navigator.pop(ctx);

                      _salvaSuFirebase(
                          nomeSottoCampo,
                          durataMinuti,
                          totale,
                          isSfida: abilitaSfida,
                          modalita: abilitaSfida ? (modalitaScelta == 0 ? 'pubblica' : 'diretta') : null,
                          avversario: (abilitaSfida && modalitaScelta == 1) ? avversarioSelezionato.trim() : null
                      );
                    },
                    child: Text(abilitaSfida
                        ? AppLocalizations.of(context)!.translate("Lancia sfida")
                        : AppLocalizations.of(context)!.translate("Conferma prenotazione")),
                  ),
                ],
              );
            }
        );
      },
    );
  }

  // --- SALVATAGGIO ---
  Future<void> _salvaSuFirebase(
      String nomeSottoCampo,
      int durataMinuti,
      double totale,
      {required bool isSfida, String? modalita, String? avversario}
      ) async {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator())
    );

    try {
      if (isSfida && modalita == 'diretta' && avversario != null) {
        bool esiste = await _checkUserExists(avversario);
        if (!esiste) {
          if (mounted) Navigator.pop(context);
          CustomSnackBar.show(context, "${AppLocalizations.of(context)!.translate("Utente")} '$avversario' ${AppLocalizations.of(context)!.translate("non trovato.")}");
          return;
        }
      }

      String nomeReale = "Utente";
      String livelloGiocatore = "Amatoriale";
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          nomeReale = data['username'] ?? data['nome'] ?? "Utente";
          livelloGiocatore = data['livello'] ?? "Amatoriale";

          if (isSfida && modalita == 'diretta' && avversario == nomeReale) {
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
              AppLocalizations.of(context)!.translate("La tua prenotazione al") +
                  " ${widget.campo.nome} " +
                  AppLocalizations.of(context)!.translate("inizia alle") +
                  " $_selectedTimeSlot.",
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
          'opponentId': null,
          'opponentName': (modalita == 'diretta') ? avversario : null,
          'nomeStruttura': widget.campo.nome,
          'campo': nomeSottoCampo,
          'indirizzo': widget.campo.indirizzo,
          'data': Timestamp.fromDate(_selectedDate),
          'ora': _selectedTimeSlot,
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
                child: Icon(Icons.sports_tennis)
                //dead code ma in futuro potrebbe avere senso se si mettono immagini su fire storage
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
                _caricaPrenotazioni();
              },
            ),
            const SizedBox(height: 25),

            if (_isLoadingPrenotazioni)
              const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ))
            else ...[
              Text(AppLocalizations.of(context)!.translate("Seleziona Orario"), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onSurfaceColor)),
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