import 'package:flutter/material.dart';
import '../../../services/sfida_consigliati_service.dart';
import '../../behaviors/AppLocalizations.dart';
import '../../pages/Chat/ChatPage.dart';
import '../EmptyWidget.dart';

class NuovaChatSfidaPopup extends StatefulWidget {
  final int mode;
  const NuovaChatSfidaPopup({super.key, required this.mode});

  @override
  State<NuovaChatSfidaPopup> createState() => _NuovaChatSfidaPopupState();
}

class _NuovaChatSfidaPopupState extends State<NuovaChatSfidaPopup> {
  final UserService userService = UserService();
  String _searchQuery = "";
  List<Map<String, dynamic>> _allUsers = [];
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadUsers();
  }
  Future<void> _loadUsers() async {
    final users = await userService.getSuggestedPlayers();
    if (!mounted) return;
    setState(() {
      _allUsers = users;
      _isLoading = false;
    });
  }

  void _handleUserTap(Map<String, dynamic> user) {
    //chiude la tastiera se aperta
    FocusScope.of(context).unfocus();
    // Se mode è 0, ritorna l'utente selezionato per la sfida nella prenotazione
    if (widget.mode == 0) {
      Navigator.pop(context, user);
    } else {
      // Altrimenti apre la chat con l'utente selezionato
      Navigator.pop(context);
      if (user['uid'] != null) {
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
  }
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.75,
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
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
          ),
          const SizedBox(height: 5),
          Text(AppLocalizations.of(context)!.translate("Sfidali o inizia una conversazione")),
          const SizedBox(height: 20),

          TextField(
            onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.translate('Cerca nella lista...'),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              isDense: true,
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildUserList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
  Widget _buildUserList() {
    if (_allUsers.isEmpty) {
      return Center(
        child: EmptyWidget(
          text: AppLocalizations.of(context)!.translate("Nessun giocatore trovato."),
          icon: Icons.person_off,
        ),
      );
    }
    final filteredUsers = _allUsers.where((user) {
      final name =
      (user['displayName'] ?? user['username'] ?? "")
          .toString()
          .toLowerCase();
      return name.contains(_searchQuery);
    }).toList();

    if (filteredUsers.isEmpty) {
      return Center(
        child: EmptyWidget(
          text: AppLocalizations.of(context)!.translate("Nessun risultato per la ricerca."),
          icon: Icons.search_off,
        ),
      );
    }

    return ListView.separated(
      itemCount: filteredUsers.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        final String name =
            user['displayName'] ?? user['username'] ?? "Giocatore";
        final String city = user['citta'] ?? "Non specificata";
        final String userLevel = user['livello'] ?? "?";

        bool isNear = user['priority'] == 1;
        String levelStatus = user['level_status'] ?? 'ok';
        Color levelColor =
        levelStatus == 'high' ? Colors.red : Colors.blue[900]!;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          leading: CircleAvatar(
            radius: 26,
            backgroundColor:
            Theme.of(context).primaryColor.withValues(alpha: 0.1),
            child: Text(name.isNotEmpty ? name[0].toUpperCase() : "?",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
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
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isNear) ...[
                _buildTag(context, AppLocalizations.of(context)!.translate("Vicino a te"), Colors.green,),
                const SizedBox(height: 4),
              ],
              _buildTag(context, AppLocalizations.of(context)!.translate(userLevel), levelColor,),
            ],
          ),
          onTap: () => _handleUserTap(user),
        );
      },
    );
  }
}