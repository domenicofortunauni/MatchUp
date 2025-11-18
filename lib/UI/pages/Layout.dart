import 'package:flutter/material.dart';
import '../behaviors/AppLocalizations.dart';
import 'Home.dart';
import 'Sfide.dart';
import 'News.dart';
import 'package:matchup/UI/pages/Login.dart';
import '../../main.dart';

class Layout extends StatefulWidget {
  final String title;

  Layout({required this.title, super.key});

  @override
  _LayoutState createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 5,
        initialIndex: 2,
        child: Scaffold(
          extendBody: true,
          drawer: _buildSettingsDrawer(context),
          appBar: AppBar(
              title: Text(widget.title,textAlign: TextAlign.center),
              centerTitle: true, // importante per centrare il titolo in Android/iOS
              backgroundColor: Theme.of(context).colorScheme.primary,
            //parte destra app bar
            actions: [
              IconButton(
                icon: Icon(Icons.logout_rounded),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const Login()),
                        (route) => false,
                  );
                },
              ),
            ],


          ),
          bottomNavigationBar: Padding(
          padding:  const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Material(
              shadowColor: Colors.transparent,
              borderRadius: BorderRadius.circular(45),
              color: Theme.of(context).colorScheme.primary,
              child: TabBar(
                dividerColor: Colors.transparent, //serve a rimuovere una strana linea grigia che usciva
                labelColor: Colors.white, // colore del testo e dell'icona quando selezionato
                unselectedLabelColor: Colors.white70, // tutto il testo non selezionato
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    width: 7.0,
                    color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.55), // colore della pagina selezionata dalla tab
                  ),
                  borderRadius: BorderRadius.circular(12), // arrotondato
                ),
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                tabs: [
                  Tab(text: AppLocalizations.of(context)!.translate("News"), icon: Icon(Icons.newspaper_outlined)),
                  Tab(text: AppLocalizations.of(context)!.translate("Chat"), icon: Icon(Icons.chat_outlined)),
                  Tab(text: AppLocalizations.of(context)!.translate("Home"), icon: Icon(Icons.home_rounded)),
                  Tab(text: AppLocalizations.of(context)!.translate("Sfida"), icon: Icon(Icons.sports_tennis_outlined)),
                  Tab(text: AppLocalizations.of(context)!.translate("Prenota"), icon: Icon(Icons.calendar_month_outlined)),
                ],
              ),
          ),
          ),
          body: TabBarView(
          children: [
            News(),
            Home(),
            Home(),
            Sfide(),
            Home(),
          ],
        ),
        )
    );
  }

  Widget _buildSettingsDrawer(BuildContext context) {
    // Recupera l'istanza dello stato globale di MyApp
    final appState = MyApp.of(context);
    // Recupera il codice della lingua corrente per il checkmark
    final currentLang = appState?.currentLocale.languageCode ?? 'it';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Text(
              'Impostazioni',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),

          // --- Sezione Lingua ---
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text('Lingua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),

          _buildLanguageTile(context, 'Italiano', 'it', appState, currentLang),
          _buildLanguageTile(context, 'English', 'en', appState, currentLang),
          _buildLanguageTile(context, 'Français', 'fr', appState, currentLang),

          const Divider(),

          // --- Sezione Tema ---
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Cambia Tema'),
            onTap: () {
              // TODO: Aggiungi qui la logica per cambiare tema (Light/Dark)
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(
      BuildContext context,
      String name,
      String code,
      MyAppState? appState,
      String currentLang
      ) {
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(name),
      onTap: () {
        // Chiama setLocale solo se appState esiste
        if (appState != null) {
          appState.setLocale(Locale(code));
        }
        Navigator.pop(context); // Chiude il Drawer
      },
      // Mostra il checkmark sulla lingua attualmente selezionata
      trailing: currentLang == code ? const Icon(Icons.check) : null,
    );
  }
}