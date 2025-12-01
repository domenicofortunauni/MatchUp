import 'package:flutter/material.dart';
import '../../../services/sfida_consigliati_service.dart';
import '../../behaviors/AppLocalizations.dart';
import '../../pages/ChatPage.dart';

class NuovaChatSfidaPopup extends StatefulWidget {
  final int mode; // 0 = Ritorna utente (Crea Sfida), 1 = Apre Chat
  const NuovaChatSfidaPopup({super.key, required this.mode});

  @override
  State<NuovaChatSfidaPopup> createState() => _NuovaChatSfidaPopupState();
}

class _NuovaChatSfidaPopupState extends State<NuovaChatSfidaPopup> {
  final UserService userService = UserService();

  String _searchQuery = "";

  // Gestione del click sull'utente
  void _handleUserTap(Map<String, dynamic> user) {
    if (widget.mode == 0) {
      // Modalità Selezione: Chiude e restituisce i dati a CreaSfida
      Navigator.pop(context, user);
    } else {
      // Modalità Chat: Chiude e apre la chat
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            receiverId: user['uid'],
            receiverName: user['displayName'] ?? user['username'] ?? "Utente",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50, height: 5,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            AppLocalizations.of(context)!.translate("Giocatori consigliati"),
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 5),
          Text(AppLocalizations.of(context)!.translate("Sfidali o inizia una conversazione")),
          const SizedBox(height: 20),

          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.translate('Cerca nella lista...'),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              isDense: true,
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: userService.getSuggestedPlayers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text(AppLocalizations.of(context)!.translate("Nessun giocatore trovato.")));
                }

                final allUsers = snapshot.data!;

                final filteredUsers = allUsers.where((user) {
                  final name = (user['displayName'] ?? user['username'] ?? "").toString().toLowerCase();
                  return name.contains(_searchQuery);
                }).toList();

                if (filteredUsers.isEmpty) {
                  return Center(child: Text(AppLocalizations.of(context)!.translate("Nessun risultato per la ricerca.")));
                }

                return ListView.separated(
                  itemCount: filteredUsers.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final String name = user['displayName'] ?? user['username'] ?? "Giocatore";
                    final String city = user['citta'] ?? "Non specificata";
                    final String tag = user['ui_tag'] ?? "";

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      leading: CircleAvatar(
                        radius: 26,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : "?",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 2),
                          Text(city, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (tag == "Vicino a te")
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green, width: 0.5)
                              ),
                              child: Text(AppLocalizations.of(context)!.translate("Vicino"), style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          const SizedBox(width: 10),
                          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
                        ],
                      ),
                      onTap: () => _handleUserTap(user),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}