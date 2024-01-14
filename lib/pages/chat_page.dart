import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:keeping_fit/chat/chat_bubble.dart';
import 'package:keeping_fit/chat/message_service.dart';
import 'package:keeping_fit/chat/my_text_field.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  const ChatPage({super.key, required this.receiverUserEmail});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _chatService = ChatService();

  void sendMessage() async {
    // only send message if there is something to send
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverUserEmail, _messageController.text);
      // clear the text controller after sending the message
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: Text(
          widget.receiverUserEmail,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 178, 173, 173),
      ),
      body: Column(children: [
        Expanded(
          child: _buildMessageList(),
        ),
        _buildMessageInput(),
        const SizedBox(
          height: 25,
        )
      ]),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
        stream: _chatService.getMessages(
          widget.receiverUserEmail,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Loading...');
          }

          return ListView(
            children: snapshot.data!.docs
                .map((document) => _buildMessageItem(document))
                .toList(),
          );
        });
  }

  // build message item
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    // align the messages to the right if the sender is the current user, otherwise to the left
    var alignment = (data['senderEmail'] == _auth.currentUser!.email)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
            crossAxisAlignment:
                (data['senderEmail'] == _auth.currentUser!.email)
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
            mainAxisAlignment: (data['senderEmail'] == _auth.currentUser!.email)
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Text(
                data['senderEmail'],
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(
                height: 5,
              ),
              ChatBubble(
                  message: data['message'],
                  receiverOrSender:
                      (data['senderEmail'] == _auth.currentUser!.email))
            ]),
      ),
    );
  }

  // build message input
  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // textfield
          Expanded(
              child: MyTextField(
            controller: _messageController,
            hintText: 'Enter message',
            obscureText: false,
          )),

          // send button
          IconButton(
              onPressed: sendMessage,
              icon: const Icon(
                Icons.arrow_upward,
                size: 40,
                color: Color.fromARGB(255, 178, 173, 173),
              ))
        ],
      ),
    );
  }
}
