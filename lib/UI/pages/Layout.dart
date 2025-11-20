import 'package:flutter/material.dart';
import '../behaviors/AppLocalizations.dart';
import 'Home.dart';
import 'Sfide.dart';
import 'News.dart';
import 'ChatList.dart';
import 'package:matchup/UI/pages/Login.dart';
import '../../main.dart';
import 'Prenota.dart';

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
              title: Image.asset(
                'assets/images/appBarLogo.png',
                height: 40,
              ),
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
                splashBorderRadius: BorderRadius.circular(45), //fix rotondità dell'overlay della tabbar!!
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
            ChatListPage(),
            Home(),
            Sfide(),
            Prenota(),
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
            title: const Text('Cambia Tema'),
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
                                ? Icons.nightlight_round
                                : Icons.sports_tennis, // icona tennis
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