import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import 'cards/giornoCalendarioCard.dart';
import 'dialogs/sceltaGiornoCalendarioDialog.dart';

class HorizontalWeekCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
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
  void didUpdateWidget(covariant HorizontalWeekCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!DateUtils.isSameDay(oldWidget.selectedDate, widget.selectedDate)) {
      final startOfList = _getStartDate();
      final diff = _stripTime(widget.selectedDate).difference(startOfList).inDays;
      final targetOffset = diff * (_itemWidth + _separatorWidth);
      if (_scrollController.hasClients)
        _scrollController.animateTo(targetOffset, duration: const Duration(milliseconds: 400), curve: Curves.easeOut,);
    }
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  // Rimuove l'ora da una data
  DateTime _stripTime(DateTime date) {return DateTime(date.year, date.month, date.day);}
  // Ottiene la data di inizio della lista
  DateTime _getStartDate() {
    final now = DateTime.now();
    if (widget.allowPastDates)
      return _stripTime(now).subtract(const Duration(days: 365));
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
    if (!DateUtils.isSameDay(now, widget.selectedDate)) {
      widget.onDateChanged(now);
    }
  }
  // Mostra il dialog di selezione della data personalizzato
  void _showCustomCalendarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => sceltaGiornoCalendarioDialog(
        selectedDate: widget.selectedDate,
        allowPastDates: widget.allowPastDates,
        primaryColor:
        widget.activeColor ?? Theme.of(context).colorScheme.primary,
        eventCountProvider: widget.eventCountProvider,
        onConfirm: widget.onDateChanged,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final String localeCode = Localizations.localeOf(context).languageCode;
    final Color primaryColor = widget.activeColor ?? Theme.of(context).colorScheme.primary;
    final Color onSurface = Theme.of(context).colorScheme.onSurface;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final DateTime today = _stripTime(DateTime.now());
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
        if (widget.showMonthHeader) const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            separatorBuilder: (ctx, i) => SizedBox(width: _separatorWidth),
            itemBuilder: (context, index) {
              final date = startDate.add(Duration(days: index));
              return giornoCalendarioCard(
                date: date,
                isSelected: DateUtils.isSameDay(date, widget.selectedDate),
                isToday: DateUtils.isSameDay(date, today),
                eventCount: widget.eventCountProvider?.call(date) ?? 0,
                onTap: () => widget.onDateChanged(date),
                width: _itemWidth,
                primaryColor: primaryColor,
                isDarkMode: isDarkMode,
                localeCode: localeCode,
              );
              },
          ),
        ),
      ],
    );
  }
}