import 'package:flutter/material.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import 'package:matchup/UI/widgets/CustomSnackBar.dart';

class prenotaDaMappa extends StatelessWidget {
  final Map<String, dynamic> tags;
  prenotaDaMappa(this.tags);

  @override
  Widget build(BuildContext context) {
    final nome = tags['name'] ?? AppLocalizations.of(context)!.translate('Campo da Tennis');
    final surface = tags['surface'] ?? AppLocalizations.of(context)!.translate('Non specificata');
    final access = tags['access'] ?? AppLocalizations.of(context)!.translate('Pubblico');
    final operator = tags['operator'] ?? AppLocalizations.of(context)!.translate('Non specificato');

    return Container(
          padding: const EdgeInsets.all(20),
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.sports_tennis, size: 40, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nome, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          operator != 'Non specificato' ? operator : AppLocalizations.of(context)!.translate("Gestore sconosciuto"),
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 30),

              ListTile(
                leading: const Icon(Icons.grass),
                title: Text(AppLocalizations.of(context)!.translate("Superficie")),
                subtitle: Text(surface.toUpperCase()),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
              ListTile(
                leading: const Icon(Icons.lock_open),
                title: Text(AppLocalizations.of(context)!.translate("Accesso")),
                subtitle: Text(access == 'private' ? AppLocalizations.of(context)!.translate("Privato / Circolo") : AppLocalizations.of(context)!.translate("Pubblico")),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    CustomSnackBar.show(context, AppLocalizations.of(context)!.translate("Funzione prenota in arrivo..."));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(AppLocalizations.of(context)!.translate("PRENOTA QUESTO CAMPO")),
                ),
              ),
            ],
          ),
        );
  }
}