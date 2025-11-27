import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import 'package:matchup/UI/widgets/HorizontalWeekCalendar.dart';

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

  // Funzione che passeremo al Calendario per i pallini rossi
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

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color onSurface = Theme.of(context).colorScheme.onSurface;

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
            HorizontalWeekCalendar(
              selectedDate: _selectedDate,
              showMonthHeader: true, // Questo gestisce anche la riga del mese e il bottone "Vai a oggi"
              allowPastDates: true,
              onDateChanged: (newDate) {
                setState(() {
                  _selectedDate = newDate;
                });
              },
              // Passiamo la logica per contare le prenotazioni (pallino rosso)
              eventCountProvider: _countPrenotazioniForDay,
            ),
            // ---------------------------------------------------------

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),

            // LISTA PRENOTAZIONI
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