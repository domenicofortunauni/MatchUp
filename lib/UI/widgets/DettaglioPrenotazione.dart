import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matchup/model/objects/CampoModel.dart';
import 'package:matchup/UI/widgets/CustomSnackBar.dart';
import 'package:matchup/UI/widgets/HorizontalWeekCalendar.dart';
import '../behaviors/AppLocalizations.dart';
import '../../services/prenotazione_service.dart';

class DettaglioPrenotazione extends StatefulWidget {
  final CampoModel campo;
  const DettaglioPrenotazione({Key? key, required this.campo}) : super(key: key);

  @override
  State<DettaglioPrenotazione> createState() => _DettaglioPrenotazioneState();
}

class _DettaglioPrenotazioneState extends State<DettaglioPrenotazione> {
  final PrenotazioneService _prenotazioneService = PrenotazioneService();
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

  Future<void> _caricaPrenotazioni() async {
    setState(() => _isLoadingPrenotazioni = true);
    try {
      final occupati = await _prenotazioneService.getOrariOccupati(widget.campo.id, _selectedDate);
      setState(() {
        _orariOccupatiPerCampo = occupati;
        _isLoadingPrenotazioni = false;
      });
    } catch (e) {
      setState(() => _isLoadingPrenotazioni = false);
    }
  }

  int _toMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  bool _isTimeSlotAvailable(String nomeSottoCampo, String startTime, int durataMinuti) {
    if (!_orariOccupatiPerCampo.containsKey(nomeSottoCampo)) return true;

    Set<int> minutiOccupati = _orariOccupatiPerCampo[nomeSottoCampo]!;
    int startMin = _toMinutes(startTime);
    int slotsNecessari = durataMinuti ~/ 30;

    for (int i = 0; i < slotsNecessari; i++) {
      int checkTime = startMin + (i * 30);
      if (minutiOccupati.contains(checkTime)) return false;
    }
    return true;
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

  // Gestione dialog e salvataggio
  Future<void> _confermaPrenotazione(String nomeSottoCampo, int durataMinuti) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      CustomSnackBar.show(context, AppLocalizations.of(context)!.translate("Devi essere loggato per prenotare"));
      return;
    }
    double totale = widget.campo.prezzoOrario * (durataMinuti / 60.0);
    String dataFormattata = DateFormat.yMd(Localizations.localeOf(context).languageCode).format(_selectedDate);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate("Conferma Prenotazione")),
        content: Text(
            "${AppLocalizations.of(context)!.translate("Struttura")}: ${widget.campo.nome}\n"
                "${AppLocalizations.of(context)!.translate("Campo")}: $nomeSottoCampo\n"
                "${AppLocalizations.of(context)!.translate("Data")}: $dataFormattata\n"
                "${AppLocalizations.of(context)!.translate("Ora")}: $_selectedTimeSlot\n"
                "${AppLocalizations.of(context)!.translate("Durata")}: $durataMinuti min\n\n"
                "${AppLocalizations.of(context)!.translate("Totale")}: €${totale.toStringAsFixed(2)}"
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context)!.translate("Annulla"))
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // Chiude dialog conferma

              // Loading Dialog
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (c) => const Center(child: CircularProgressIndicator())
              );

              try {
                // Recupero nome utente (Opzionale: potresti usare UserSession qui!)
                String nomeReale = user.displayName ?? "Utente";

                await _prenotazioneService.creaPrenotazione(
                  uid: user.uid,
                  nomeUtente: nomeReale,
                  campoId: widget.campo.id,
                  nomeStruttura: widget.campo.nome,
                  indirizzo: widget.campo.indirizzo,
                  nomeSottoCampo: nomeSottoCampo,
                  data: _selectedDate,
                  oraInizio: _selectedTimeSlot!,
                  durata: durataMinuti,
                  prezzo: totale,
                );

                await _caricaPrenotazioni();

                if (mounted) {
                  Navigator.pop(context); // Chiude loading
                  Navigator.pop(context); // Chiude pagina dettaglio
                  CustomSnackBar.show(context, AppLocalizations.of(context)!.translate("Prenotazione confermata!"));
                }

              } catch (e) {
                if (mounted) {
                  Navigator.pop(context); // Chiude loading
                  CustomSnackBar.show(context, AppLocalizations.of(context)!.translate("Errore durante la prenotazione"));
                }
              }
            },
            child: Text(AppLocalizations.of(context)!.translate("Conferma")),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scorciatoia per le traduzioni
    final t = AppLocalizations.of(context)!;

    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color secondaryColor = Theme.of(context).colorScheme.secondary;
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        // Qui gestiamo la traduzione se il nome è "Sconosciuto" dal model
        title: Text(widget.campo.nome == "Campo Sconosciuto"
            ? t.translate("Campo sconosciuto")
            : widget.campo.nome),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... Header Immagine ...
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: Icon(Icons.sports_tennis, size: 80, color: primaryColor)),
            ),
            const SizedBox(height: 20),

            Text(widget.campo.nome, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: onSurfaceColor)),
            Text("${widget.campo.indirizzo}, ${widget.campo.citta}", style: TextStyle(color: onSurfaceColor.withValues(alpha: 0.6), fontSize: 16)),
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
              const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
            else ...[
              // Titolo Tradotto
              Text(t.translate("Seleziona Orario"), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onSurfaceColor)),
              const SizedBox(height: 10),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, childAspectRatio: 2.0, crossAxisSpacing: 8, mainAxisSpacing: 8,
                ),
                itemCount: _allDailySlots.length,
                itemBuilder: (context, index) {
                  final time = _allDailySlots[index];
                  final isSelected = _selectedTimeSlot == time;
                  return InkWell(
                    onTap: () {
                      setState(() => _selectedTimeSlot = time);
                      _scrollToBottom();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : (isDarkMode ? secondaryColor : Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(time, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              if (_selectedTimeSlot != null) ...[
                const Divider(),
                const SizedBox(height: 10),
                if (widget.campo.campiDisponibili.isEmpty)
                  Text(t.translate("Nessun campo disponibile"))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.campo.campiDisponibili.length,
                    itemBuilder: (ctx, index) {
                      final nomeSottoCampo = widget.campo.campiDisponibili[index];
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
                                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                child: Text(t.translate("Già prenotato in questo orario"), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              ),
                            )
                          else
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [60, 90, 120].map((durata) {
                                  if (!_isTimeSlotAvailable(nomeSottoCampo, _selectedTimeSlot!, durata)) return const SizedBox.shrink();

                                  double prezzo = widget.campo.prezzoOrario * (durata / 60.0);
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: InkWell(
                                      onTap: () => _confermaPrenotazione(nomeSottoCampo, durata),
                                      child: Container(
                                        width: 110, height: 75,
                                        decoration: BoxDecoration(color: secondaryColor, borderRadius: BorderRadius.circular(12)),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text("${prezzo.toStringAsFixed(2)} €", style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 20, fontWeight: FontWeight.bold)),
                                            Text("$durata min", style: TextStyle(color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.8), fontSize: 14)),
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