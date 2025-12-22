import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:matchup/model/objects/CampoModel.dart';
import 'package:matchup/UI/widgets/popup/NuovaChatSfida.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';

class confermaPrenotazioneDialog extends StatefulWidget {
  final CampoModel campo;
  final String nomeSottoCampo;
  final DateTime data;
  final String ora;
  final int durataMinuti;
  final double totale;
  final bool tipoPrenotazione;
  final Function({
  required bool isSfida,
  String? modalita,
  String? avversarioUsername,
  String? avversarioUid,
  }) onConferma;

  const confermaPrenotazioneDialog({
    super.key,
    required this.campo,
    required this.nomeSottoCampo,
    required this.data,
    required this.ora,
    required this.durataMinuti,
    required this.totale,
    required this.tipoPrenotazione,
    required this.onConferma,
  });

  @override
  State<confermaPrenotazioneDialog> createState() => _confermaPrenotazioneDialogState();
}
class _confermaPrenotazioneDialogState
    extends State<confermaPrenotazioneDialog> {

  bool abilitaSfida = false;
  int modalitaScelta = 0;
  String? avversarioUsername;
  String? avversarioUid;
  late final locale = Localizations.localeOf(context).languageCode;
  late final dataFormattata = DateFormat.yMd(locale).format(widget.data);


  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    abilitaSfida = widget.tipoPrenotazione;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.translate("Completa Prenotazione")),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${AppLocalizations.of(context)!.translate("Struttura: ")}${widget.campo.nome}"),
            Text("${AppLocalizations.of(context)!.translate("Campo: ")}${widget.nomeSottoCampo}"),
            Text("${AppLocalizations.of(context)!.translate("Data: ")}${dataFormattata} - ${AppLocalizations.of(context)!.translate("Ore: ")}${widget.ora}"),
            Text("${AppLocalizations.of(context)!.translate("Totale: ")}€${widget.totale.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),

            const Divider(height: 30),

            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.translate("Vuoi lanciare una sfida?"), style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(AppLocalizations.of(context)!.translate("Crea una partita pubblica o sfida un amico")),
              activeThumbColor: Theme.of(context).colorScheme.primary,
              contentPadding: EdgeInsets.zero,
              value: abilitaSfida,
              onChanged: widget.tipoPrenotazione ? null : (val) => setState(() => abilitaSfida = val),

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
                          setState(() => modalitaScelta = val);
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
                            setState(() {
                              controller.text = selectedUser['displayName'] ?? selectedUser['username'] ?? "";

                              avversarioUsername = selectedUser['username'];
                              avversarioUid = selectedUser['uid'];
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
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.translate("Annulla")),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: abilitaSfida ? Theme.of(context).primaryColor : Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            if (abilitaSfida && modalitaScelta == 1 && avversarioUid == null) {
              return;
            }

            Navigator.pop(context);
            widget.onConferma(
              isSfida: abilitaSfida,
              modalita: abilitaSfida
                  ? (modalitaScelta == 0 ? 'pubblica' : 'diretta')
                  : null,
              avversarioUsername: avversarioUsername,
              avversarioUid: avversarioUid,
            );
          },

          child: Text(abilitaSfida
              ? AppLocalizations.of(context)!.translate("Lancia sfida")
              : AppLocalizations.of(context)!.translate("Conferma prenotazione")),
        ),
      ],
    );
  }
}