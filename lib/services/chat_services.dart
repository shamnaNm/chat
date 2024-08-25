import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:async/async.dart'; // For StreamZip
import 'package:chat/models/chat_models.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(ChatMessage chatMessage) async {
    try {
      await _firestore.collection('messages').add({
        'senderId': chatMessage.senderId,
        'receiverId': chatMessage.receiverId,
        'senderName': chatMessage.senderName,
        'receiverName': chatMessage.receiverName,
        'message': chatMessage.message,
        'timestamp': chatMessage.timestamp,
      });
    } catch (e) {
      print('Failed to send message: $e');
    }
  }

  Stream<List<ChatMessage>> getChatMessages(String senderId, String receiverId) {
    final sentMessagesStream = _firestore
        .collection('messages')
        .where('senderId', isEqualTo: senderId)
        .where('receiverId', isEqualTo: receiverId)
        .orderBy('timestamp')
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) => ChatMessage.fromDocument(doc)).toList();
    });

    final receivedMessagesStream = _firestore
        .collection('messages')
        .where('senderId', isEqualTo: receiverId)
        .where('receiverId', isEqualTo: senderId)
        .orderBy('timestamp')
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) => ChatMessage.fromDocument(doc)).toList();
    });

    // Combine the streams and sort messages
    return StreamZip([sentMessagesStream, receivedMessagesStream])
        .map((messagesLists) {
      // Flatten the list of lists and sort by timestamp
      final allMessages = messagesLists.expand((list) => list).toList();
      allMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return allMessages;
    });
  }
}
