import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../behaviors/AppLocalizations.dart';
import '../../widgets/chat/chatListItem.dart';
import '../../widgets/EmptyWidget.dart';
import '../../widgets/popup/NuovaChatSfida.dart';
import '../../widgets/buttons/CircularFloatingIconButton.dart';
import 'ChatPage.dart';
import '../../../services/chat_service.dart';

class ChatListPage extends StatelessWidget {
  ChatListPage({super.key});

  final ChatService _chatService = ChatService();
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate("Chat")),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: _chatService.getMyChats(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text(AppLocalizations.of(context)!.translate("Errore")));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child:
                  EmptyWidget(
                    text: AppLocalizations.of(context)!.translate("Nessuna conversazione attiva."),
                    icon: Icons.chat_bubble_outline,
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
              final Map<String, dynamic> unreadMap = data['unreadCount'] ?? {};
              final int unreadCount = unreadMap[currentUserId] ?? 0;

              return ChatListItem(
                title: title,
                lastMessage: lastMessage,
                unreadCount: unreadCount,
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ChatPage(receiverId: otherUserId, receiverName: title),
                  ));
                },
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