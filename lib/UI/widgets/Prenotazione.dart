import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import 'package:matchup/UI/widgets/HorizontalWeekCalendar.dart';
import 'package:matchup/UI/widgets/CustomSnackBar.dart';

//MODELLO DATI
class Prenotazione {
  final String id;
  final String nomeStruttura;
  final String campo;
  final DateTime data;
  final String ora;
  final int durata;
  final double prezzo;
  final String stato;

  Prenotazione({
    required this.id,
    required this.nomeStruttura,
    required this.campo,
    required this.data,
    required this.ora,
    required this.durata,
    required this.prezzo,
    required this.stato,
  });

  factory Prenotazione.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime dataEvento = DateTime.now();

    // Gestione Timestamp di Firebase
    if (data['data'] != null) {
      dataEvento = (data['data'] as Timestamp).toDate();
    }

    return Prenotazione(
      id: doc.id,
      nomeStruttura: data['nomeStruttura'] ?? 'Struttura sconosciuta',
      campo: data['nomeSottoCampo'] ?? 'Campo',
      data: dataEvento,
      ora: data['oraInizio'] ?? '00:00',
      durata: data['durataMinuti'] ?? 60,
      prezzo: (data['prezzoTotale'] ?? 0).toDouble(),
      stato: data['stato'] ?? "Confermato",
    );
  }
}

class PrenotazioniWidget extends StatefulWidget {
  const PrenotazioniWidget({Key? key}) : super(key: key);

  @override
  State<PrenotazioniWidget> createState() => _PrenotazioniWidgetState();
}

class _PrenotazioniWidgetState extends State<PrenotazioniWidget> {
  DateTime _selectedDate = DateTime.now();
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  late Stream<QuerySnapshot> _prenotazioniStream;

  @override
  void initState() {
    super.initState();
    if (currentUserId.isNotEmpty) {
      _prenotazioniStream = FirebaseFirestore.instance
          .collection('prenotazioni')
          .where('userId', isEqualTo: currentUserId)
          .orderBy('data', descending: false)
          .snapshots();
    }
  }

  String _getDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  //LOGICA ANNULLAMENTO
  Future<void> _annullaPrenotazione(Prenotazione p) async {
    if (p.data.isBefore(DateTime.now().subtract(const Duration(hours: 1)))) {
      CustomSnackBar.show(context, "Non puoi annullare prenotazioni passate!");
      return;
    }

    bool conferma = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Annulla Prenotazione"),
        content: Text("Vuoi davvero annullare la prenotazione presso ${p.nomeStruttura}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Sì, annulla", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (!conferma) return;

    try {
      await FirebaseFirestore.instance
          .collection('prenotazioni')
          .doc(p.id)
          .update({'stato': 'Annullato'});

      if (mounted) {
        CustomSnackBar.show(context, "Prenotazione annullata con successo.");
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(context, "Errore: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color onSurface = Theme.of(context).colorScheme.onSurface;

    if (currentUserId.isEmpty) {
      return const Center(child: Text("Effettua il login per vedere le prenotazioni"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _prenotazioniStream,
      builder: (context, snapshot) {

        if (snapshot.hasError) return Center(child: Text("Errore: ${snapshot.error}"));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
        }

        final docs = snapshot.data!.docs;
        Map<String, List<Prenotazione>> mappaPrenotazioni = {};

        for (var doc in docs) {
          Prenotazione p = Prenotazione.fromSnapshot(doc);
          String key = _getDateKey(p.data);

          if (!mappaPrenotazioni.containsKey(key)) {
            mappaPrenotazioni[key] = [];
          }
          mappaPrenotazioni[key]!.add(p);
        }

        int countPrenotazioniFast(DateTime date) {
          String key = _getDateKey(date);
          if (mappaPrenotazioni.containsKey(key)) {
            return mappaPrenotazioni[key]!
                .where((p) => p.stato != "Annullato")
                .length;
          }
          return 0;
        }

        String selectedKey = _getDateKey(_selectedDate);
        List<Prenotazione> prenotazioniDelGiorno = mappaPrenotazioni[selectedKey] ?? [];

        return Card(
          elevation: 4.0,
          margin: const EdgeInsets.all(12.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)?.translate("Le Tue Prenotazioni") ?? "Le Tue Prenotazioni",
                      style: const TextStyle(
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
                  showMonthHeader: true,
                  allowPastDates: true,
                  onDateChanged: (newDate) {
                    setState(() {
                      _selectedDate = newDate;
                    });
                  },
                  eventCountProvider: countPrenotazioniFast,
                ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),

                if (prenotazioniDelGiorno.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.event_available, size: 40, color: Colors.grey.shade300),
                          const SizedBox(height: 10),
                          Text(
                            AppLocalizations.of(context)?.translate("Nessuna prenotazione") ?? "Nessuna prenotazione",
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
                    itemCount: prenotazioniDelGiorno.length,
                    itemBuilder: (context, index) {
                      final pren = prenotazioniDelGiorno[index];
                      bool isAnnullato = pren.stato == "Annullato";

                      //CALCOLO SE LA PRENOTAZIONE È PASSATA
                      bool isPassata = false;
                      try {
                        List<String> parts = pren.ora.split(':');
                        int hour = int.parse(parts[0]);
                        int minute = int.parse(parts[1]);

                        // Creo la data completa di orario inizio
                        DateTime startDateTime = DateTime(
                            pren.data.year,
                            pren.data.month,
                            pren.data.day,
                            hour,
                            minute
                        );

                        // Aggiungo la durata per capire quando finisce
                        DateTime endDateTime = startDateTime.add(Duration(minutes: pren.durata));

                        // Controllo se è già finita rispetto ad adesso
                        isPassata = endDateTime.isBefore(DateTime.now());
                      } catch (e) {
                        // Se c'è un errore nel parsing data, fallback a false
                        isPassata = false;
                      }

                      // Colore icona: Grigio se passata, Rosso se annullata, Primary se attiva
                      Color iconColor;
                      if (isAnnullato) iconColor = Colors.red;
                      else if (isPassata) iconColor = Colors.grey;
                      else iconColor = primaryColor;

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
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

                          // ICONA A SINISTRA
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: iconColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                                isAnnullato ? Icons.cancel_outlined :
                                (isPassata ? Icons.check_circle_outline : Icons.sports_tennis),
                                color: iconColor
                            ),
                          ),

                          // INFO
                          title: Text(
                            pren.nomeStruttura,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                // Se passata o annullata, rendiamo il testo un po' meno evidente
                                color: (isAnnullato || isPassata) ? Colors.grey : onSurface
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(pren.campo, style: const TextStyle(fontSize: 13)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${pren.ora} (${pren.durata}m)",
                                    style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // PARTE DESTRA (Logica visualizzazione)
                          trailing: Builder(
                            builder: (context) {
                              if (isAnnullato) {
                                return const Text(
                                  "Annullata",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                );
                              }
                              if (isPassata) {
                                return const Text(
                                  "Terminata",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                );
                              }
                              return IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _annullaPrenotazione(pren),
                                tooltip: "Annulla prenotazione",
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}