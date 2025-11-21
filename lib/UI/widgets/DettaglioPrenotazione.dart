import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:matchup/UI/pages/Prenota.dart';
import 'package:matchup/UI/widgets/CustomSnackBar.dart';

class DettaglioPrenotazione extends StatefulWidget {
  final CampoModel campo;

  const DettaglioPrenotazione({Key? key, required this.campo}) : super(key: key);

  @override
  State<DettaglioPrenotazione> createState() => _DettaglioPrenotazioneState();
}

class _DettaglioPrenotazioneState extends State<DettaglioPrenotazione> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _calendarScrollController = ScrollController();

  // Data selezionata (inizialmente oggi)
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;

  final List<String> _campiDisponibili = ["Campo 1", "Campo 2 (Panoramico)"];

  final List<String> _allDailySlots = [
    "16:30", "17:00", "17:30", "18:00",
    "18:30", "19:00", "19:30", "20:00",
    "20:30", "21:00", "21:30", "22:00",
    "22:30", "23:00"
  ];

  final Set<String> _bookedSlots = {"18:00", "18:30", "21:00"};

  @override
  void dispose() {
    _scrollController.dispose();
    _calendarScrollController.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int _toMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  List<String> _getSelectableSlots() {
    List<String> selectable = [];
    Set<int> bookedMinutes = _bookedSlots.map(_toMinutes).toSet();
    Set<int> allClubMinutes = _allDailySlots.map(_toMinutes).toSet();

    for (String slot in _allDailySlots) {
      int startMin = _toMinutes(slot);
      if (bookedMinutes.contains(startMin)) continue;
      if (allClubMinutes.contains(startMin + 30) && !bookedMinutes.contains(startMin + 30)) {
        selectable.add(slot);
      }
    }
    return selectable;
  }

  List<int> _getAvailableDurations(String startTime) {
    List<int> possibleDurations = [60, 90, 120];
    List<int> validDurations = [];

    int startMinutes = _toMinutes(startTime);
    Set<int> bookedMinutes = _bookedSlots.map(_toMinutes).toSet();
    Set<int> allClubMinutes = _allDailySlots.map(_toMinutes).toSet();

    for (int duration in possibleDurations) {
      bool isPossible = true;
      int slotsNeeded = duration ~/ 30;
      for (int i = 0; i < slotsNeeded; i++) {
        int checkTime = startMinutes + (i * 30);
        if (!allClubMinutes.contains(checkTime) || bookedMinutes.contains(checkTime)) {
          isPossible = false;
          break;
        }
      }
      if (isPossible) validDurations.add(duration);
    }
    return validDurations;
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

  // Apre il calendario completo
  Future<void> _pickDateFromCalendar(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && !_isSameDay(picked, _selectedDate)) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeSlot = null;
      });
    }
  }

  // Imposta la data a oggi
  void _resetToToday() {
    final now = DateTime.now();

    if (_calendarScrollController.hasClients) {
      _calendarScrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuart,
      );
    }

    if (!_isSameDay(now, _selectedDate)) {
      setState(() {
        _selectedDate = now;
        _selectedTimeSlot = null;
      });
    }
  }

  void _confermaPrenotazione(String nomeCampo, int durataMinuti) {
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
                "$nomeCampo\n"
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
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              CustomSnackBar.show(context, "Prenotazione confermata!");
            },
            child: const Text("Conferma"),
          ),
        ],
      ),
    );
  }

  //Calendario orizzontale
  Widget _buildHorizontalCalendar(BuildContext context) {
    final String localeCode = Localizations.localeOf(context).languageCode;
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color onSurface = Theme.of(context).colorScheme.onSurface;
    final Color secondaryColor = Theme.of(context).colorScheme.secondary;

    String monthYear = DateFormat.yMMMM(localeCode).format(_selectedDate);
    monthYear = toBeginningOfSentenceCase(monthYear) ?? monthYear;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              monthYear,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: onSurface,
              ),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: _resetToToday,
                  child: const Text("vai a oggi", style: TextStyle(fontSize: 14)),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today_outlined),
                  onPressed: () => _pickDateFromCalendar(context),
                  color: onSurface,
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 10),


        SizedBox(
          height: 90,
          child: ListView.separated(
            controller: _calendarScrollController,
            scrollDirection: Axis.horizontal,
            itemCount: 30,
            separatorBuilder: (ctx, i) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index));

              final bool isSelected = _isSameDay(date, _selectedDate);
              final bool isToday = _isSameDay(date, DateTime.now());

              String dayName = DateFormat('EEE', localeCode).format(date).toUpperCase(); // LUN, MAR...
              String dayNumber = DateFormat('d', localeCode).format(date); // 20, 21...

              Color bgColor = isSelected ? primaryColor : secondaryColor;
              Color textColor = isSelected ? Colors.white : Colors.black;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                    _selectedTimeSlot = null;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 70,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Text(
                        dayName,
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.7),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),

                      Text(
                        dayNumber,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),

                      if (isToday) ...[
                        const SizedBox(height: 4),
                        Text(
                          "oggi",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                      ] else
                        const SizedBox(height: 17),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> selectableSlots = _getSelectableSlots();
    List<int> availableDurations = _selectedTimeSlot != null
        ? _getAvailableDurations(_selectedTimeSlot!)
        : [];

    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color secondaryColor = Theme.of(context).colorScheme.secondary;
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;

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
            // Immagine
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

            // Info
            Text(
              widget.campo.nome,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: onSurfaceColor),
            ),
            Text(
              "${widget.campo.indirizzo}, ${widget.campo.citta}",
              style: TextStyle(color: onSurfaceColor.withValues(alpha: 0.6), fontSize: 16),
            ),
            const Divider(height: 30),

            _buildHorizontalCalendar(context),

            const SizedBox(height: 25),

            // Orari
            Text("Seleziona Orario", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onSurfaceColor)),
            const SizedBox(height: 10),
            if (selectableSlots.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Nessun orario disponibile.", style: TextStyle(color: onSurfaceColor.withValues(alpha: 0.5))),
              )
            else
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

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedTimeSlot = time;
                      });
                      _scrollToBottom();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : secondaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        time,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 30),

            //lista campi e opzioni
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

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _campiDisponibili.length,
                itemBuilder: (ctx, index) {
                  final nomeCampo = _campiDisponibili[index];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.arrow_right, size: 24, color: primaryColor),
                            Text(nomeCampo, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: onSurfaceColor)),
                          ],
                        ),
                      ),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (availableDurations.isNotEmpty)
                              ...availableDurations.map((durata) {
                                double prezzo = widget.campo.prezzoOrario * (durata / 60.0);

                                return Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  child: InkWell(
                                    onTap: () => _confermaPrenotazione(nomeCampo, durata),
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
                                            style: TextStyle(
                                                color: Theme.of(context).colorScheme.onSecondary,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold
                                            ),
                                          ),
                                          Text(
                                            _formatDurationText(durata),
                                            style: TextStyle(
                                                color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.8),
                                                fontSize: 14
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList()
                            else
                              const Text("Non disponibile.", style: TextStyle(color: Colors.red)),

                            if (availableDurations.isNotEmpty)
                              InkWell(
                                onTap: () => _confermaPrenotazione(nomeCampo, 60),
                                child: Container(
                                  width: 110,
                                  height: 75,
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Sii il primo", style: TextStyle(color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8), fontSize: 11)),
                                      Text("Organizza!", style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                          ],
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
        ),
      ),
    );
  }
}