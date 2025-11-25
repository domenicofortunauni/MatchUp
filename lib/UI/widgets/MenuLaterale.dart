import 'package:flutter/material.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import 'package:matchup/main.dart';
import 'package:matchup/UI/pages/News.dart';

class MenuLaterale extends StatelessWidget {
  final Widget? headerImage;

  const MenuLaterale({super.key, required this.headerImage});

  @override
  Widget build(BuildContext context) {
    //Recupera l'istanza dello stato globale di MyApp
    final appState = MyApp.of(context);
    //Recupera il codice della lingua corrente
    final currentLang = appState?.currentLocale.languageCode ?? 'it';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, //Allinea a sinistra
                mainAxisAlignment: MainAxisAlignment.center,  //Centra verticalmente
                children: [
                    Expanded(child: headerImage!),
                    const SizedBox(height: 10), //Spazio tra immagine e testo
                ],
            ),
          ),

          //Sezione Lingua
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              AppLocalizations.of(context)!.translate("Lingua"),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),

          _buildLanguageTile(context, 'Italiano', '🇮🇹', 'it', appState, currentLang),
          _buildLanguageTile(context, 'English',  '🇬🇧', 'en', appState, currentLang),
          _buildLanguageTile(context, 'Français', '🇫🇷', 'fr', appState, currentLang),
          _buildLanguageTile(context, 'Español',  '🇪🇸', 'es', appState, currentLang),
          _buildLanguageTile(context, 'Deutsch', '🇩🇪', 'de', appState, currentLang),

          const Divider(),

          //Sezione Tema
          ListTile(
            title: Text(AppLocalizations.of(context)!.translate("Cambia Tema")),
            trailing: GestureDetector(
              onTap: () {
                final appState = MyApp.of(context);
                appState?.toggleTheme();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 70,
                height: 35,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.blue[800]
                      : Colors.green[400],
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      left: Theme.of(context).brightness == Brightness.dark ? 35 : 0,
                      right: Theme.of(context).brightness == Brightness.dark ? 0 : 35,
                      child: Container(
                        width: 27,
                        height: 27,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.yellow[700], // pallina da tennis
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              offset: const Offset(2, 2),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Theme.of(context).brightness == Brightness.dark
                                ? Icons.sports_tennis
                                : Icons.sports_tennis,
                            size: 16,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.green[900],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.newspaper), // Icona giornale
            title: Text(AppLocalizations.of(context)!.translate("News")),
            onTap: () {
              //Chiude il Drawer laterale
              Navigator.pop(context);

              //Naviga alla pagina News
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const News()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(
      BuildContext context,
      String name,
      String flag,
      String code,
      MyAppState? appState,
      String currentLang,
      ) {
    return ListTile(
      leading: Text(
        flag,
        style: const TextStyle(fontSize: 24),
      ),
      title: Text(name),
      onTap: () {
        if (appState != null) {
          appState.setLocale(Locale(code));
        }
        Navigator.pop(context);
      },
      trailing: currentLang == code ? const Icon(Icons.check) : null,
    );
  }
}