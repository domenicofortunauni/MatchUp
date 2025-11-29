import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _getChatId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return "${ids[0]}_${ids[1]}";
  }

  Stream<QuerySnapshot> getMyChats() {
    final currentUid = _auth.currentUser!.uid;

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  Future<void> sendMessage(String receiverId, String messageText, String myName, String receiverName) async {
    final currentUserId = _auth.currentUser!.uid;
    final String chatId = _getChatId(currentUserId, receiverId);

    final chatDocRef = _firestore.collection('chats').doc(chatId);
    final messagesRef = chatDocRef.collection('messages');
    final Timestamp now = Timestamp.now();

    final newMessage = {
      'senderId': currentUserId,
      'receiverId': receiverId,
      'text': messageText,
      'timestamp': now,
      'isRead': false,
    };

    try {
      await messagesRef.add(newMessage);

      await chatDocRef.set({
        'participants': [currentUserId, receiverId],
        'userNames': {
          currentUserId: myName,
          receiverId: receiverName
        },
        'lastMessage': messageText,
        'lastMessageTime': now,
      }, SetOptions(merge: true));

    } catch (e) {
      print("Errore invio -per debug: $e");
      rethrow;
    }
  }

  Stream<QuerySnapshot> getMessages(String receiverId) {
    final currentUserId = _auth.currentUser!.uid;
    final String chatId = _getChatId(currentUserId, receiverId);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}