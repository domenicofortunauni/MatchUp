import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../behaviors/AppLocalizations.dart';
import '../widgets/popup/NuovaChat.dart';
import '../widgets/buttons/CircularFloatingIconButton.dart';
import 'ChatPage.dart';
import '../../services/chat_service.dart';

class ChatListPage extends StatelessWidget {
  ChatListPage({super.key});

  final ChatService _chatService = ChatService();
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate("Chat")),
        elevation: 0,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: _chatService.getMyChats(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text(AppLocalizations.of(context)!.translate("Errore")));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text(AppLocalizations.of(context)!.translate("Nessuna conversazione attiva."), style: const TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final List<dynamic> participants = data['participants'] ?? [];
              final String otherUserId = participants.firstWhere(
                      (id) => id != currentUserId, orElse: () => "Sconosciuto");
              final Map<String, dynamic> names = data['userNames'] ?? {};
              final String title = names[otherUserId] ?? "Utente";
              final String lastMessage = data['lastMessage'] ?? '';

              // Recupera unreadCount per l'utente corrente
              final Map<String, dynamic> unreadMap = data['unreadCount'] ?? {};
              final int unreadCount = unreadMap[currentUserId] ?? 0;

              return Column(
                children: [
                  ListTile(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ChatPage(receiverId: otherUserId, receiverName: title),
                      ));
                    },
                    leading: CircleAvatar(
                      child: Text(title.isNotEmpty ? title[0].toUpperCase() : "?"),
                    ),
                    title: Text(
                        title,
                        style: TextStyle(
                            fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal
                        )
                    ),
                    subtitle: Text(
                        lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal
                        )
                    ),
                    trailing: unreadCount > 0
                        ? Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                        : null,
                  ),
                  const Divider(height: 1),
                ],
              );
            },
          );
        },
      ),

      floatingActionButton: CircularFloatingIconButton(
        onPressed: () => _apriNuovaChat(context),
        icon: Icons.comment,
      ),
    );
  }
  void _apriNuovaChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) =>  NuovaChatSfidaPopup(mode: 1)
    );
  }
}