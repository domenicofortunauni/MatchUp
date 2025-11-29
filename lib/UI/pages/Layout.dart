import 'package:flutter/material.dart';
import '../behaviors/AppLocalizations.dart';
import '../widgets/dialogs/logoutDialog.dart';
import 'Home.dart';
import 'Sfide.dart';
import 'ChatList.dart';
import 'Tornei.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'Prenota.dart';
import 'package:matchup/UI/widgets/MenuLaterale.dart';

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
          drawer: MenuLaterale(
            headerImage: Image.asset('assets/images/appBarLogo.png',
            height: 60,
            fit: BoxFit.contain,
          ),
          ),
          appBar: AppBar(
              title: Image.asset(
                'assets/images/appBarLogo.png',
                height: 40,
              ),
              centerTitle: true,
              backgroundColor: Theme.of(context).colorScheme.primary,
              iconTheme: const IconThemeData(color: Colors.white),
            //parte destra app bar
            actions: [
              IconButton(
                icon: Icon(Icons.logout_rounded),
                tooltip: AppLocalizations.of(context)!.translate("Logout"),
                onPressed: () => LogoutDialog.show(context),
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
                  Tab(text: AppLocalizations.of(context)!.translate("Tornei"), icon: Icon(FontAwesomeIcons.trophy)),
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
            TorneiPage(),
            ChatListPage(),
            Home(),
            Sfide(),
            Prenota(),
          ],
        ),
        )
    );
  }
}