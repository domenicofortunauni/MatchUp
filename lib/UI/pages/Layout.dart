import 'package:flutter/material.dart';
import '../behaviors/AppLocalizations.dart';
import 'Home.dart';

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
        child: Scaffold(
          extendBody: true,
          appBar: AppBar(title: Text(widget.title),
              backgroundColor: Theme.of(context).colorScheme.primary
          ),
          bottomNavigationBar: Padding(
          padding:  const EdgeInsets.fromLTRB(10, 0, 10, 12),
          child: Material(
              shadowColor: Colors.transparent,
              borderRadius: BorderRadius.circular(45),
              color: Theme.of(context).colorScheme.primary,
              child: TabBar(
                dividerColor: Colors.transparent, //serve a rimuovere una strana linea grigia che usciva
                labelColor: Colors.white70, // colore del testo e dell'icona quando selezionato
                unselectedLabelColor: Colors.white, // tutto il testo non selezionato
                indicator: BoxDecoration(
                  color: Colors.grey, // colore della pagina selezionata dalla tab
                  borderRadius: BorderRadius.circular(12), // arrotondato
                ),
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                tabs: [
                  Tab(text: AppLocalizations.of(context)?.translate("News") ?? "News", icon: Icon(Icons.newspaper_outlined)),
                  Tab(text: AppLocalizations.of(context)?.translate("Chat") ?? "Chat", icon: Icon(Icons.chat_outlined)),
                  Tab(text: AppLocalizations.of(context)?.translate("Home") ?? "Home", icon: Icon(Icons.home_rounded)),
                  Tab(text: AppLocalizations.of(context)?.translate("Sfida") ?? "Sfida", icon: Icon(Icons.sports_tennis_outlined)),
                  Tab(text: AppLocalizations.of(context)?.translate("Prenota") ?? "Prenota", icon: Icon(Icons.calendar_month_outlined)),
                ],
              ),
          ),
          ),
          body: TabBarView(
          children: [
            Home(),
            Home(),
            Home(),
            Home(),
            Home(),
          ],
        ),
        )

    );
  }
}