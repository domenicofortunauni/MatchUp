import 'package:flutter/material.dart';
import '../behaviors/AppLocalizations.dart';
import 'Home.dart';
import 'News.dart';
import 'package:matchup/UI/pages/Login.dart';
import 'Sfide.dart';

class Layout extends StatefulWidget {
  final String title;


  Layout({required this.title}) : super();

  @override
  _LayoutState createState() => _LayoutState(title);
}

class _LayoutState extends State<Layout> {
  late String title;


  _LayoutState(String title) {
    this.title = title;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 5,
        initialIndex: 2,
        child: Scaffold(
          extendBody: true,
          appBar: AppBar(
              title: Text(widget.title,textAlign: TextAlign.center),
              centerTitle: true, // importante per centrare il titolo in Android/iOS
              backgroundColor: Theme.of(context).colorScheme.primary,
             //Parte sinistra della app bar
              leading: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
              // TODO: Menù con selezione tema, lingua, impostazioni app
              },
          ),
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
}