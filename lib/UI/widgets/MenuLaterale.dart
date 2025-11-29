import 'package:flutter/material.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import 'package:matchup/main.dart';
import 'package:matchup/UI/pages/News.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuLaterale extends StatelessWidget {
  final Widget? headerImage;

  const MenuLaterale({super.key, required this.headerImage});

  //Funzione per generare le iniziali
  String _getInitials(String nome, String cognome) {
    String n = nome.isNotEmpty ? nome[0].toUpperCase() : "";
    String c = cognome.isNotEmpty ? cognome[0].toUpperCase() : "";
    return "$n$c";
  }

  @override
  Widget build(BuildContext context) {
    final appState = MyApp.of(context);
    final currentLang = appState?.currentLocale.languageCode ?? 'it';
    final User? currentUser = FirebaseAuth.instance.currentUser; // Utente corrente

    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: currentUser == null
                      ? _buildLogoHeader() // Se non loggato, mostra logo
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
                  title: Text(AppLocalizations.of(context)!.translate("Cambia Tema"),
                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
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
        Expanded(child: headerImage ?? const SizedBox()),
        const SizedBox(height: 10),
      ],
    );
  }

  //Dati utente
  Widget _buildUserHeader(User user, BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 50, color: Colors.white),
              Text("Errore caricamento profilo", style: TextStyle(color: Colors.white)),
            ],
          );
        }
        var userData = snapshot.data!.data() as Map<String, dynamic>;
        String nome = userData['nome'] ?? '';
        String cognome = userData['cognome'] ?? '';
        String username = userData['username'] ?? '';
        String email = userData['email'] ?? user.email ?? '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0,0,0,10),
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
      },
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