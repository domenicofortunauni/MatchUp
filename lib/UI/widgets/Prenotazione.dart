import 'package:flutter/material.dart';
import 'package:matchup/UI/widgets/CustomSnackBar.dart';

class Prenotazione {
  final String campo;
  final String data;
  final String ora;
  final String stato;

  Prenotazione({
    required this.campo,
    required this.data,
    required this.ora,
    required this.stato,
  });
}

class PrenotazioniWidget extends StatefulWidget {
  final List<Prenotazione> prenotazioni;

  const PrenotazioniWidget({super.key, required this.prenotazioni});

  @override
  State<PrenotazioniWidget> createState() => _PrenotazioniWidgetState();
}

class _PrenotazioniWidgetState extends State<PrenotazioniWidget> {
  final ScrollController _scrollController = ScrollController();

  bool _isCalendarView = false;
  late DateTime _selectedDate;
  late DateTime _focusedMonth;

  final List<String> _mesi = [
    '', 'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
    'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = now;
    _focusedMonth = DateTime(now.year, now.month, 1);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  DateTime _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return DateTime(1970);
    try {
      String cleanDate = dateString.trim();
      try { return DateTime.parse(cleanDate); } catch (_) {}
      String normalized = cleanDate.replaceAll('-', '/').replaceAll('.', '/');
      final parts = normalized.split('/');
      if (parts.length == 3) {
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int year = int.parse(parts[2]);
        if (year < 100) year += 2000;
        return DateTime(year, month, day);
      }
    } catch (e) {}
    return DateTime(1970);
  }

  TimeOfDay _parseTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return const TimeOfDay(hour: 0, minute: 0);
    try {
      String cleanTime = timeString.trim().replaceAll('.', ':');
      final parts = cleanTime.split(':');
      if (parts.length >= 2) {
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    } catch (e) {}
    return const TimeOfDay(hour: 0, minute: 0);
  }

  DateTime _getFullDateTime(Prenotazione p) {
    DateTime date = _parseDate(p.data);
    TimeOfDay time = _parseTime(p.ora);
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  int _countPrenotazioniForDay(DateTime day) {
    return widget.prenotazioni.where((p) => _isSameDay(_parseDate(p.data), day)).length;
  }

  // Logica calendario
  int _getDaysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;
  int _getFirstDayOffset(int year, int month) => DateTime(year, month, 1).weekday;
  void _changeMonth(int increment) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + increment, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Prenotazione> listaDaMostrare = _isCalendarView
        ? widget.prenotazioni.where((p) => _isSameDay(_parseDate(p.data), _selectedDate)).toList()
        : widget.prenotazioni.toList();

    listaDaMostrare.sort((a, b) {
      return _getFullDateTime(a).compareTo(_getFullDateTime(b));
    });

    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Le Tue Prenotazioni",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Bottone "oggi"
                      if (_isCalendarView)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              final now = DateTime.now();
                              _selectedDate = now; // Seleziona oggi
                              _focusedMonth = DateTime(now.year, now.month, 1); // Torna al mese corrente
                            });
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white, // Colore testo
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            "OGGI",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),

                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isCalendarView = !_isCalendarView;
                            if (_isCalendarView) {
                              final now = DateTime.now();
                              _selectedDate = now;
                              _focusedMonth = DateTime(now.year, now.month, 1);
                            }
                          });
                        },
                        icon: Icon(
                          _isCalendarView ? Icons.list_alt_rounded : Icons.calendar_month_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (_isCalendarView) _buildCustomCalendar(),

            if (listaDaMostrare.isNotEmpty)
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: _isCalendarView ? 200 : 350),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: ListView.builder(
                    controller: _scrollController,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: listaDaMostrare.length,
                    padding: const EdgeInsets.only(right: 8.0),
                    itemBuilder: (context, index) {
                      final p = listaDaMostrare[index];
                      return _buildPrenotazioneCard(p);
                    },
                  ),
                ),
              )
            else
              _buildEmptyState(),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomCalendar() {
    final baseDate = _focusedMonth;
    final int daysInMonth = _getDaysInMonth(baseDate.year, baseDate.month);
    final int firstWeekday = _getFirstDayOffset(baseDate.year, baseDate.month);
    final int emptySlots = firstWeekday - 1;

    String nomeMese = "";
    if (baseDate.month >= 1 && baseDate.month <= 12) nomeMese = _mesi[baseDate.month];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    icon: const Icon(Icons.chevron_left, size: 22),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _changeMonth(-1)
                ),
                Text("$nomeMese ${baseDate.year}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(
                    icon: const Icon(Icons.chevron_right, size: 22),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _changeMonth(1)
                ),
              ],
            ),
          ),

          // Giorni settimana
          Padding(
            padding: const EdgeInsets.only(bottom: 4, top: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ["L", "M", "M", "G", "V", "S", "D"]
                  .map((d) => SizedBox(
                  width: 32,
                  child: Center(child: Text(d, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)))
              ))
                  .toList(),
            ),
          ),

          // Griglia giorni
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 2.3,
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
            ),
            itemCount: emptySlots + daysInMonth,
            itemBuilder: (context, index) {
              if (index < emptySlots) return const SizedBox();

              final int dayNum = index - emptySlots + 1;
              final DateTime dayDate = DateTime(baseDate.year, baseDate.month, dayNum);
              final bool isSelected = _isSameDay(dayDate, _selectedDate);
              final bool isToday = _isSameDay(dayDate, DateTime.now());
              final int count = _countPrenotazioniForDay(dayDate);

              return GestureDetector(
                onTap: () => setState(() => _selectedDate = dayDate),
                child: Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Cerchio del giorno
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : (isToday ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2) : Colors.transparent),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            "$dayNum",
                            style: TextStyle(
                              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),

                      // Badge del numerino
                      if (count > 0)
                        Positioned(
                          right: -6,
                          top: -6,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                              border: Border.all(color: Theme.of(context).colorScheme.surface, width: 1.5),
                            ),
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                            child: Center(
                              child: Text(
                                "$count",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrenotazioneCard(Prenotazione p) {
    return Card(
      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (p.stato == "Confermato" ? Colors.green : Colors.grey).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.sports_tennis, color: p.stato == "Confermato" ? Colors.green : Colors.grey, size: 28),
        ),
        title: Text(p.campo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text("${p.data} • ${p.ora}", style: const TextStyle(fontSize: 14)),
        ),
        trailing: Chip(
          label: Text(p.stato, style: const TextStyle(color: Colors.white, fontSize: 12)),
          backgroundColor: p.stato == "Confermato" ? Colors.green : Colors.redAccent,
        ),
        onTap: () => CustomSnackBar.show(context, 'Prenotazione di ${p.campo}'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Icon(_isCalendarView ? Icons.event_busy : Icons.inbox, size: 40, color: Colors.grey.withValues(alpha: 0.4)),
            const SizedBox(height: 8),
            Text(
              _isCalendarView
                  ? "Nessuna prenotazione il ${_selectedDate.day}/${_selectedDate.month}"
                  : "Non hai prenotazioni attive!",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}