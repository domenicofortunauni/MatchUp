import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//chat_service recuperato da pub.dev
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
      // Logica per contatori messaggi
      await chatDocRef.set({
        'participants': [currentUserId, receiverId],
        'userNames': {
          currentUserId: myName,
          receiverId: receiverName
        },
        'lastMessage': messageText,
        'lastMessageTime': now,
        'unreadCount': {
          receiverId: FieldValue.increment(1)
        }
      }, SetOptions(merge: true));
    } catch (e) {
      print("Errore invio --per debug: $e");
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

// Segna messaggi come letti e resetta il contatore
  Future<void> markMessagesAsRead(String receiverId) async {
    final currentUserId = _auth.currentUser!.uid;
    final String chatId = _getChatId(currentUserId, receiverId);
    final chatDoc = _firestore.collection('chats').doc(chatId);

    try {
      // Resetta il contatore per l'utente
      await chatDoc.set({
        'unreadCount': {
          currentUserId: 0
        }
      }, SetOptions(merge: true));

      // Marca come letti i messaggi non letti
      final messagesRef = chatDoc.collection('messages');
      final unreadMessages = await messagesRef
          .where('receiverId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in unreadMessages.docs) {
        await doc.reference.update({'isRead': true});
      }
    } catch (e) {
      print("Errore: $e");
    }
  }

// Stream per contare i messaggi totali non letti
  Stream<int> getTotalUnreadCount() {
    final currentUid = _auth.currentUser!.uid;
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUid)
        .snapshots()
        .map((snapshot) {
      int total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final unreadMap = data['unreadCount'] as Map<String, dynamic>?;
        if (unreadMap != null && unreadMap.containsKey(currentUid)) {
          total += (unreadMap[currentUid] as int?) ?? 0;
        }
      }
      return total;
    });
  }
}