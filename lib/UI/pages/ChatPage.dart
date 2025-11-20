import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

class SingleChatPage extends StatefulWidget {
  final String threadId;
  final String chatTitle;

  const SingleChatPage({
    super.key,
    required this.threadId,
    required this.chatTitle,
  });

  @override
  SingleChatPageState createState() => SingleChatPageState();
}

class SingleChatPageState extends State<SingleChatPage> {
  // InMemoryChatController va sostituito con FireStore credo
  final _chatController = InMemoryChatController();

  @override
  void initState() {
    super.initState();
    // Qui potresti chiamare una funzione per caricare i messaggi
    // iniziali usando widget.threadId, ad esempio:
    // _loadMessages(widget.threadId);

    // messaggio iniziale fittizio:
    _chatController.insertMessage(
      TextMessage(
        id: 'initial_msg',
        authorId: 'user2', // Un altro utente
        createdAt: DateTime.now().toUtc().subtract(const Duration(minutes: 5)),
        text: 'Benvenuto nella chat ${widget.chatTitle} ',
      ),
    );
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.chatTitle), // Usiamo il titolo passato
      ),
      body: Chat(
        theme: ChatTheme.fromThemeData(Theme.of(context)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        chatController: _chatController,
        currentUserId: 'user1',
        onMessageSend: (text) {
          // Logica per inviare il messaggio al backend usando widget.threadId
          _chatController.insertMessage(
            TextMessage(
              // Better to use UUID or similar for the ID - IDs must be unique
              id: '${Random().nextInt(1000) + 1}',
              authorId: 'user1',
              createdAt: DateTime.now().toUtc(),
              text: text,
            ),
          );
        },
        resolveUser: (UserID id) async {
          // Risolvi i nomi degli utenti
          return User(
            id: id,
            name: id == 'user1' ? 'Tu' : 'Amico', // Esempio di risoluzione
          );
        },
      ),
    );
  }
}