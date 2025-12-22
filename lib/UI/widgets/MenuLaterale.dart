import 'package:flutter/material.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import 'package:matchup/main.dart';
import 'package:matchup/UI/pages/News.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuLaterale extends StatelessWidget {
  static final Widget headerImage = Image.asset('assets/images/appBarLogo.png',height: 60, fit: BoxFit.contain);
  const MenuLaterale({super.key});

  static Stream<DocumentSnapshot>? userStream;
  Stream<DocumentSnapshot> _getUserStream(String uid) {
    userStream ??= FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots();
    return userStream!;
  }

  //Funzione per generare le iniziali
  String _getInitials(String nome, String cognome) {
    String getFirst(String s) =>
        s.trim().isNotEmpty ? s.trim()[0].toUpperCase() : '';
    return "${getFirst(nome)}${getFirst(cognome)}";
  }

  @override
  Widget build(BuildContext context) {
    final appState = MyApp.of(context);
    final currentLang = Localizations.localeOf(context).languageCode;
    final User? currentUser = FirebaseAuth.instance.currentUser; // Utente corrente

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: currentUser == null ? _buildLogoHeader() // Se non loggato, mostra logo
                : _buildUserHeader(currentUser, context), // Se loggato, mostra dati
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
            leading: Theme.of(context).brightness == Brightness.light? const Icon(Icons.dark_mode) : const Icon(Icons.light_mode),
            title: Text(AppLocalizations.of(context)!.translate("Cambia tema")),
            trailing: Switch(
              inactiveThumbColor: Theme.of(context).colorScheme.primary,
              inactiveTrackColor: Theme.of(context).colorScheme.primary.withValues(alpha:0.7),
              trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (_) {MyApp.of(context).toggleTheme();},
              thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
                return const Icon(Icons.sports_tennis, size: 16,);
                },),
            ),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.newspaper),
            title: Text(AppLocalizations.of(context)!.translate("News")),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const News()),
              );
            },
          ),
        ],
      ),
    );
  }

  //Logo
  Widget _buildLogoHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: headerImage),
        const SizedBox(height: 10),
      ],
    );
  }

  //Dati utente
  Widget _buildUserHeader(User user, BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _getUserStream(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off, size: 50, color: Colors.white),
              Text(AppLocalizations.of(context)!.translate("Errore caricamento profilo"), style: const TextStyle(color: Colors.white)),
            ],
          );
        }
        var userData = snapshot.data!.data() as Map<String, dynamic>;
        String nome = userData['nome'] ?? '';
        String cognome = userData['cognome'] ?? '';
        String username = userData['username'] ?? '';
        String email = userData['email'] ?? user.email ?? '';

        return _buildUserUI(nome, cognome, username, email, context,);
        },
    );
  }
  Widget _buildUserUI(String nome, String cognome, String username, String email, BuildContext context,) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0,0,0,15),
          child: Image.asset(
              'assets/images/appBarLogo.png',
              height: 40,
            ),
          ),
        Row(
          children: [
            //Avatar con iniziali
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                _getInitials(nome, cognome),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            const SizedBox(width: 15),
            //Informazioni
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$nome $cognome",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if(username.isNotEmpty)
                    Text(
                      "@$username",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  Row(
                    children: [const Icon(Icons.email, size: 14, color: Colors.white70),
                      const SizedBox(width: 1),
                      Text(
                        email,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ]
                  ),
                ],
              ),
            ),
          ]
        )
      ],
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
      leading: Text(flag, style: const TextStyle(fontSize: 24),),
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