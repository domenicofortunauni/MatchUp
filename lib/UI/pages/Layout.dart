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
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text(widget.title),
        ),
          bottomNavigationBar: Material(
              color: Colors.green,
              child: TabBar(
                labelColor: Colors.white, // colore testo selezionato
                unselectedLabelColor: Colors.white70, // testo non selezionato
                indicatorColor: Colors.white, // sottolineatura dell’elemento attivo
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