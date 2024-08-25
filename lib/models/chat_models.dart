import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String senderId;
  final String receiverId;
  final String senderName;
  final String receiverName;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.senderId,
    required this.receiverId,
    required this.senderName,
    required this.receiverName,
    required this.message,
    required this.timestamp,
  });

  // Factory constructor to create ChatMessage from a Firestore document
  factory ChatMessage.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      senderId: data['senderId'] as String,
      receiverId: data['receiverId'] as String,
      senderName: data['senderName'] as String,
      receiverName: data['receiverName'] as String,
      message: data['message'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}

