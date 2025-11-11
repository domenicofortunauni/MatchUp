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
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
          bottomNavigationBar: Material(
              color: Theme.of(context).colorScheme.inversePrimary,
              child: TabBar(
                tabs: [
                  Tab(text: AppLocalizations.of(context)?.translate("News"), icon: Icon(Icons.newspaper_outlined)),
                  Tab(text: AppLocalizations.of(context)?.translate("Chat"), icon: Icon(Icons.chat_outlined)),
                  Tab(text: AppLocalizations.of(context)?.translate("Home"), icon: Icon(Icons.home_rounded)),
                  Tab(text: AppLocalizations.of(context)?.translate("Sfida"), icon: Icon(Icons.sports_tennis_outlined)),
                  Tab(text: AppLocalizations.of(context)?.translate("Prenota"), icon: Icon(Icons.calendar_month_outlined)),
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