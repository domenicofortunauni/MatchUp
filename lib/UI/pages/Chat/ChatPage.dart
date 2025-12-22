import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/chat_service.dart';
import '../../behaviors/AppLocalizations.dart';
import '../../widgets/chat/chatInput.dart';
import '../../widgets/EmptyWidget.dart';
import '../../widgets/chat/message.dart';

class ChatPage extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  const ChatPage({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _chatService.markMessagesAsRead(widget.receiverId);
  }

  void sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    String myName = FirebaseAuth.instance.currentUser?.displayName ?? "Io";

    await _chatService.sendMessage(
        widget.receiverId,
        _messageController.text.trim(),
        myName,
        widget.receiverName
    );
    _messageController.clear();
    _scrollDown();
  }
  void _scrollDown() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              child: Text(widget.receiverName[0].toUpperCase()),
            ),
            const SizedBox(width: 10),
            Text(widget.receiverName),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _chatService.getMessages(widget.receiverId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                       child: EmptyWidget(
                          text: AppLocalizations.of(context)!.translate("Nessun messaggio"),
                          icon: Icons.chat_bubble_outline,
                        ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;

                // Scroll in fondo dopo che i messaggi son stati scaricati
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: docs.length,
                  padding: const EdgeInsets.only(bottom: 20, top: 10),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final bool isMe = data['senderId'] == currentUserId;
                    final String text = data['text'];
                    final Timestamp? ts = data['timestamp'];
                    final DateTime time = ts != null ? ts.toDate() : DateTime.now();
                    return Message(message: text, isMe: isMe, time: time);
                  },
                );
              },
            ),
          ),
          ChatInputBar(
            controller: _messageController,
            onSend: sendMessage,
          ),
        ],
      ),
    );
  }
}