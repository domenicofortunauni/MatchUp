import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';

class HorizontalWeekCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;
  final int Function(DateTime)? eventCountProvider;
  final Color? activeColor;
  final bool showMonthHeader;
  final bool allowPastDates;

  const HorizontalWeekCalendar({
    Key? key,
    required this.selectedDate,
    required this.onDateChanged,
    this.eventCountProvider,
    this.activeColor,
    this.showMonthHeader = true,
    required this.allowPastDates,
  }) : super(key: key);

  @override
  State<HorizontalWeekCalendar> createState() => _HorizontalWeekCalendarState();
}

class _HorizontalWeekCalendarState extends State<HorizontalWeekCalendar> {
  late ScrollController _scrollController;

  final double _itemWidth = 70.0;
  final double _separatorWidth = 12.0;

  @override
  void initState() {
    super.initState();

    double initialOffset = 0.0;

    if (widget.allowPastDates) {
      final startOfList = _getStartDate();
      final difference = widget.selectedDate.difference(startOfList).inDays;
      initialOffset = difference * (_itemWidth + _separatorWidth);
    }

    _scrollController = ScrollController(initialScrollOffset: initialOffset);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime _stripTime(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  int _getDaysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;
  int _getFirstDayOffset(int year, int month) => DateTime(year, month, 1).weekday;

  DateTime _getStartDate() {
    final now = DateTime.now();
    if (widget.allowPastDates) {
      return _stripTime(now).subtract(const Duration(days: 365));
    }
    return _stripTime(now);
  }

  void _resetToToday() {
    final now = DateTime.now();

    double targetOffset = 0.0;
    if (widget.allowPastDates) {
      final startOfList = _getStartDate();
      final diff = _stripTime(now).difference(startOfList).inDays;
      targetOffset = diff * (_itemWidth + _separatorWidth);
    }

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuart,
      );
    }
    if (!_isSameDay(now, widget.selectedDate)) {
      widget.onDateChanged(now);
    }
  }

  void _showCustomCalendarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        DateTime tempSelectedDate = widget.selectedDate;
        DateTime focusedMonth = DateTime(tempSelectedDate.year, tempSelectedDate.month, 1);
        final primaryColor = widget.activeColor ?? Theme.of(context).colorScheme.primary;
        final today = _stripTime(DateTime.now());

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

            final List<String> giorniSettimana = [
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
                  //Navigazione Mese
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
                    height: 300,
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

                        final bool isSelected = _isSameDay(dayDate, tempSelectedDate);
                        final bool isToday = _isSameDay(dayDate, DateTime.now());

                        bool isDisabled = !widget.allowPastDates && dayDate.isBefore(today);

                        final int count = (widget.eventCountProvider != null && !isDisabled)
                            ? widget.eventCountProvider!(dayDate)
                            : 0;

                        return GestureDetector(
                          onTap: isDisabled ? null : () {
                            setDialogState(() {
                              tempSelectedDate = dayDate;
                            });
                          },
                          child: Opacity(
                            opacity: isDisabled ? 0.3 : 1.0, //Rende trasparente se disabilitato
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? primaryColor
                                        : (isToday ? primaryColor.withValues(alpha: 0.2) : Colors.transparent),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "$dayNum",
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black,
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
                    widget.onDateChanged(tempSelectedDate);
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.translate("Conferma")),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String localeCode = Localizations.localeOf(context).languageCode;
    final Color primaryColor = widget.activeColor ?? Theme.of(context).colorScheme.primary;
    final Color secondaryColor = Theme.of(context).colorScheme.secondary;
    final Color onSurface = Theme.of(context).colorScheme.onSurface;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    String monthYear = DateFormat.yMMMM(localeCode).format(widget.selectedDate);
    monthYear = toBeginningOfSentenceCase(monthYear) ?? monthYear;

    //Data da cui partire per generare la lista
    final startDate = _getStartDate();

    final int itemCount = widget.allowPastDates ? 800 : 60;

    return Column(
      children: [
        if (widget.showMonthHeader)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthYear,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: onSurface,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: _resetToToday,
                    child: Text(
                      AppLocalizations.of(context)!.translate("Vai a oggi"),
                      style: TextStyle(fontSize: 14,color: Theme.of(context).colorScheme.onSurface ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_month_outlined),
                    onPressed: () => _showCustomCalendarDialog(context),
                    color: Theme.of(context).colorScheme.primary,
                    tooltip: AppLocalizations.of(context)!.translate("Scegli data"),
                  ),
                ],
              ),
            ],
          ),

        if (widget.showMonthHeader) const SizedBox(height: 10),

        SizedBox(
          height: 100,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            separatorBuilder: (ctx, i) => SizedBox(width: _separatorWidth),
            itemBuilder: (context, index) {

              final date = startDate.add(Duration(days: index));

              final bool isSelected = _isSameDay(date, widget.selectedDate);
              final bool isToday = _isSameDay(date, DateTime.now());

              final int eventCount = widget.eventCountProvider != null
                  ? widget.eventCountProvider!(date)
                  : 0;

              String dayName = DateFormat('EEE', localeCode).format(date).toUpperCase();
              String dayNumber = DateFormat('d', localeCode).format(date);

              Color bgColor;
              Color borderColor;

              if (isSelected) {
                bgColor = primaryColor;
                borderColor = primaryColor;
              } else {
                bgColor = isDarkMode ? secondaryColor : Colors.grey.shade100;
                borderColor = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;
              }

              Color textColor = isSelected ? Colors.white : Colors.black;

              return InkWell(
                onTap: () => widget.onDateChanged(date),
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: _itemWidth,
                      height: 90,
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: borderColor,
                            width: 1.5
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: primaryColor.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))]
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
                          ]
                        ],
                      ),
                    ),

                    if (eventCount > 0)
                      Positioned(
                        top: -5,
                        right: -5,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
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
      ],
    );
  }
}