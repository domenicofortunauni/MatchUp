import 'package:flutter/material.dart';
import 'ChatPage.dart';
import '../../model/ChatPreview.dart';
//TODO: MAagari portarle su behavior?

// struttura pagina chat

class ChatListPage extends StatelessWidget {
   ChatListPage({super.key});

  // Dati fittizi per lista delle chat
  final List<ChatPreview> _mockThreads = [
    ChatPreview(
      id: 'marco_thread',
      title: 'Marco',
      lastMessage: 'Finiamo l\'app?',
      lastMessageTime: DateTime(2025, 11, 19, 17, 30),
      unreadCount: 999,
    ),
    ChatPreview(
      id: 'domenico_thread',
      title: 'Domenico',
      lastMessage: 'Ho finito.',
      lastMessageTime: DateTime(2025, 11, 19, 14, 05),
      unreadCount: 103,
    ),
    ChatPreview(
      id: 'andrea_thread',
      title: 'Andrea',
      lastMessage: 'Ok, grazie per l\'informazione!',
      lastMessageTime: DateTime(2025, 11, 18, 09, 15),
      unreadCount: 100,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: _mockThreads.length,
        itemBuilder: (context, index) {
          final thread = _mockThreads[index];
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                // Navigazione alla chat singola
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      //  l'ID e il Titolo alla SingleChatPage
                      builder: (context) => SingleChatPage(
                        threadId: thread.id,
                        chatTitle: thread.title,
                      ),
                    ),
                  );
                },
                // Fotoprofilo utente
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blueGrey,
                  child: Text(
                    thread.title[0], // Iniziale del nome
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),

                // Titolo e ultimo Messaggio
                title: Text(
                  thread.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(
                  thread.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: thread.unreadCount > 0 ? Theme.of(context).colorScheme.inverseSurface : Colors.grey,
                  ),
                ),

                // Ora e Contatore non letti
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${thread.lastMessageTime.hour}:${thread.lastMessageTime.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 12,
                        color: thread.unreadCount > 0 ? Theme.of(context).primaryColor : Colors.grey,
                      ),
                    ),
                    if (thread.unreadCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).primaryColor,
                          ),
                          child: Text(
                            '${thread.unreadCount}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1, indent: 80), // Linea separatrice
            ],
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0, right: 5.0),
        child: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 4,
          onPressed: () {
            // TODO: Logica per avviare una nuova chat con un altro utente registrato/ al campo?
          },
          child: const Icon(Icons.message),
        ),
      ),
    );
  }
}