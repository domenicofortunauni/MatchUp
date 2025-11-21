import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';


class Prenotazione {
  final String campo;
  final String data; // Formato "dd/MM/yyyy"
  final String ora;
  final String stato; // "Confermato", "In attesa", "Annullato"

  Prenotazione({
    required this.campo,
    required this.data,
    required this.ora,
    required this.stato,
  });
}

class PrenotazioniWidget extends StatefulWidget {
  final List<Prenotazione> prenotazioni;

  const PrenotazioniWidget({Key? key, required this.prenotazioni}) : super(key: key);

  @override
  State<PrenotazioniWidget> createState() => _PrenotazioniWidgetState();
}

class _PrenotazioniWidgetState extends State<PrenotazioniWidget> {
  DateTime _selectedDate = DateTime.now();

  DateTime _parseDate(String dateStr) {
    try {
      return DateFormat("dd/MM/yyyy").parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int _countPrenotazioniForDay(DateTime date) {
    return widget.prenotazioni.where((p) {
      final pDate = _parseDate(p.data);
      return _isSameDay(pDate, date) && p.stato != AppLocalizations.of(context)!.translate("Annullato");
    }).length;
  }

  List<Prenotazione> _getPrenotazioniSelected() {
    return widget.prenotazioni.where((p) {
      final pDate = _parseDate(p.data);
      return _isSameDay(pDate, _selectedDate);
    }).toList();
  }

  Color _getStatusColor(String stato) {
    switch (stato) {
      case "Confermato": return Colors.green;
      case "In attesa": return Colors.orange;
      case "Annullato": return Colors.red;
      default: return Colors.grey;
    }
  }

  int _getDaysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;
  int _getFirstDayOffset(int year, int month) => DateTime(year, month, 1).weekday;

  void _showCustomCalendarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        DateTime focusedMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            void changeMonth(int increment) {
              setDialogState(() {
                focusedMonth = DateTime(focusedMonth.year, focusedMonth.month + increment, 1);
              });
            }

            final baseDate = focusedMonth;
            final int daysInMonth = _getDaysInMonth(baseDate.year, baseDate.month);
            final int firstWeekday = _getFirstDayOffset(baseDate.year, baseDate.month);
            final int emptySlots = firstWeekday - 1;

            final String localeCode = Localizations.localeOf(context).languageCode;
            String nomeMese = DateFormat.yMMMM(localeCode).format(baseDate);
            nomeMese = toBeginningOfSentenceCase(nomeMese) ?? nomeMese;

            final List<String> giorniSettimana = [AppLocalizations.of(context)!.translate("Lunedì1"),
            AppLocalizations.of(context)!.translate("Martedì1"),
            AppLocalizations.of(context)!.translate("Mercoledì1"),
            AppLocalizations.of(context)!.translate("Giovedì1"),
            AppLocalizations.of(context)!.translate("Venerdì1"),
            AppLocalizations.of(context)!.translate("Sabato1"),
            AppLocalizations.of(context)!.translate("Domenica1"),];

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              contentPadding: const EdgeInsets.all(12),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => changeMonth(-1),
                      ),
                      Text(
                        nomeMese,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => changeMonth(1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: giorniSettimana.map((d) {
                      return SizedBox(
                        width: 32,
                        child: Center(
                          child: Text(
                            d,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),

                  SizedBox(
                    height: 250,
                    width: 300,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1.0,
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
                          onTap: () {
                            setState(() {
                              _selectedDate = dayDate;
                            });
                            Navigator.pop(context);
                          },
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : (isToday ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2) : Colors.transparent),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "$dayNum",
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (count > 0)
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Theme.of(context).cardColor, width: 1.5),
                                    ),
                                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                    alignment: Alignment.center,
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
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color onSurface = Theme.of(context).colorScheme.onSurface;
    final String localeCode = Localizations.localeOf(context).languageCode;

    String monthYear = DateFormat.yMMMM(localeCode).format(_selectedDate);
    monthYear = toBeginningOfSentenceCase(monthYear) ?? monthYear;

    final selectedPrenotazioni = _getPrenotazioniSelected();

    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.translate("Le Tue Prenotazioni"),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  monthYear,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: onSurface
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate = DateTime.now();
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(AppLocalizations.of(context)!.translate("Vai a oggi")),
                    ),
                    const SizedBox(width: 8),

                    // TASTO ESTENDI CALENDARIO
                    IconButton(
                      icon: const Icon(Icons.calendar_month_outlined),
                      color: onSurface,
                      onPressed: () => _showCustomCalendarDialog(context),
                      tooltip: AppLocalizations.of(context)!.translate("Scegli data"),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 15),

            // CALENDARIO ORIZZONTALE
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 35,
                separatorBuilder: (ctx, i) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  // Partiamo da 5 giorni fa
                  final date = DateTime.now().add(Duration(days: index - 5));

                  final bool isSelected = _isSameDay(date, _selectedDate);
                  final bool isToday = _isSameDay(date, DateTime.now());
                  final int eventCount = _countPrenotazioniForDay(date);

                  String dayName = DateFormat('EEE', localeCode).format(date).toUpperCase();
                  String dayNumber = DateFormat('d', localeCode).format(date);

                  Color bgColor = isSelected ? primaryColor : Colors.grey.shade100;
                  Color textColor = isSelected ? Colors.white : onSurface;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 70,
                          height: 90,
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: isSelected
                                ? [BoxShadow(color: primaryColor.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0,4))]
                                : [],
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
                                  AppLocalizations.of(context)!.translate("oggi"),
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                ),
                              ] else const SizedBox(height: 17),
                            ],
                          ),
                        ),

                        if (eventCount > 0)
                          Positioned(
                            top: -5,
                            right: -5,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                eventCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),

            //  LISTA PRENOTAZIONI
            if (selectedPrenotazioni.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.event_available, size: 40, color: Colors.grey.shade300),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context)!.translate("Nessuna prenotazione"),
                        style: TextStyle(color: onSurface.withValues(alpha: 0.5)),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: selectedPrenotazioni.length,
                itemBuilder: (context, index) {
                  final pren = selectedPrenotazioni[index];
                  Color statusColor = _getStatusColor(pren.stato);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.sports_tennis, color: primaryColor),
                      ),
                      title: Text(
                        pren.campo,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                pren.ora,
                                style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          pren.stato,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}