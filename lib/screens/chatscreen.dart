import 'package:chat/models/chat_models.dart';
import 'package:chat/services/chat_services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatScreen({super.key, required this.receiverId, required this.receiverName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final User? _loggedInUser = FirebaseAuth.instance.currentUser;

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;

    final chatMessage = ChatMessage(
      senderId: _loggedInUser!.uid,
      receiverId: widget.receiverId,
      senderName: _loggedInUser!.displayName ?? 'Anonymous',
      receiverName: widget.receiverName,
      message: _messageController.text.trim(),
      timestamp: DateTime.now(),
    );

    _chatService.sendMessage(chatMessage);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatService.getChatMessages(_loggedInUser!.uid, widget.receiverId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No messages.'));
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  reverse: false, // Ensure messages are displayed from oldest to newest
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return ListTile(
                      title: Align(
                        alignment: message.senderId == _loggedInUser!.uid
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: message.senderId == _loggedInUser!.uid
                                ? Color(0xffb0cbea)
                                : Color(0xfff1f1f1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(message.message),
                        ),
                      ),
                      subtitle: Align(
                        alignment: message.senderId == _loggedInUser!.uid
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Text(
                          '${message.timestamp.hour}:${message.timestamp.minute}',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Message...',
                      border: OutlineInputBorder(

                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
