import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';

class sceltaGiornoCalendarioDialog extends StatefulWidget {
  final DateTime selectedDate;
  final bool allowPastDates;
  final Color primaryColor;
  final int Function(DateTime)? eventCountProvider;
  final ValueChanged<DateTime> onConfirm;

  const sceltaGiornoCalendarioDialog({
    Key? key,
    required this.selectedDate,
    required this.allowPastDates,
    required this.primaryColor,
    required this.onConfirm,
    this.eventCountProvider,
  }) : super(key: key);
  @override
  State<sceltaGiornoCalendarioDialog> createState() => _sceltaGiornoCalendarioDialogState();
}

class _sceltaGiornoCalendarioDialogState extends State<sceltaGiornoCalendarioDialog> {
  late DateTime tempSelectedDate;
  late DateTime focusedMonth;

  @override
  void initState() {
    super.initState();
    tempSelectedDate = widget.selectedDate;
    focusedMonth = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      1,
    );
  }
  bool _isSameDay(DateTime a, DateTime b){ return (a.year == b.year && a.month == b.month && a.day == b.day);}
  DateTime _stripTime(DateTime d){ return DateTime(d.year, d.month, d.day);}
  int _daysInMonth(DateTime d){ return DateTime(d.year, d.month + 1, 0).day;}
  int _firstDayOffset(DateTime d) { return DateTime(d.year, d.month, 1).weekday;}

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode;
    final today = _stripTime(DateTime.now());
    String nomeMese = DateFormat.yMMMM(localeCode).format(focusedMonth);
    nomeMese = toBeginningOfSentenceCase(nomeMese) ?? nomeMese;
    final daysInMonth = _daysInMonth(focusedMonth);
    final emptySlots = _firstDayOffset(focusedMonth) - 1;

    final giorniSettimana = [
      AppLocalizations.of(context)!.translate("Lunedì1"),
      AppLocalizations.of(context)!.translate("Martedì1"),
      AppLocalizations.of(context)!.translate("Mercoledì1"),
      AppLocalizations.of(context)!.translate("Giovedì1"),
      AppLocalizations.of(context)!.translate("Venerdì1"),
      AppLocalizations.of(context)!.translate("Sabato1"),
      AppLocalizations.of(context)!.translate("Domenica1"),
    ];

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    //anno mese -giorno 1
                    focusedMonth = DateTime(focusedMonth.year, focusedMonth.month - 1, 1);
                  });
                },
              ),

              Text(nomeMese, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    //anno mese -giorno 1
                    focusedMonth = DateTime(focusedMonth.year, focusedMonth.month + 1, 1);
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 8),
          // giorni settimana
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: giorniSettimana.map((inizialeGiorno) =>
                SizedBox(
                  width: 32,
                  child: Center(
                    child: Text(inizialeGiorno, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                )
            ).toList(),
          ),

          const SizedBox(height: 8),
          // giorni del mese
          SizedBox(
            height: 250,
            width: 300,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
              ),
              itemCount: emptySlots + daysInMonth,
              itemBuilder: (context, index) {
                if (index < emptySlots) return const SizedBox();
                final dayNum = index - emptySlots + 1;
                final dayDate = DateTime(focusedMonth.year, focusedMonth.month, dayNum);
                final isSelected = _isSameDay(dayDate, tempSelectedDate);
                final isToday = _isSameDay(dayDate, today);
                final isDisabled = !widget.allowPastDates && dayDate.isBefore(today);
                final count = (widget.eventCountProvider != null && !isDisabled) ? widget.eventCountProvider!(dayDate) : 0;

                return GestureDetector(
                  onTap: isDisabled ? null : () => setState(() {tempSelectedDate = dayDate;}),
                  child: Opacity(
                    opacity: isDisabled ? 0.3 : 1,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isSelected ? widget.primaryColor : (isToday ? widget.primaryColor.withValues(alpha: 0.2) : Colors.transparent),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "$dayNum",
                            style: TextStyle(
                              color: isSelected ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.inverseSurface,
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
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text("$count", style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.translate("Annulla")),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onConfirm(tempSelectedDate);
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.translate("Conferma")),
        ),
      ],
    );
  }
}
