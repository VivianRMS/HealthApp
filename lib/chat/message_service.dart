import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:keeping_fit/chat/message.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  // send message
  Future<void> sendMessage(String chatRoomId, String message) async {
    // get current user info
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();

    final Timestamp timestamp = Timestamp.now();

    List<String> receiverEmail = chatRoomId.split('_');
    receiverEmail.remove(currentUserEmail);
    print(receiverEmail.length == 1 && receiverEmail[0] == "ai");

    if (receiverEmail.length == 1 && receiverEmail[0] == "ai") {
      await getAIMessage(chatRoomId, message);
    } else {
      // create a new message
      Message newMessage = Message(
          message: message,
          senderEmail: currentUserEmail,
          receiverEmail: receiverEmail,
          timestamp: timestamp);

      // construct chat room id from current user id and receiver id (sorted to ensure uniqueness)
      // List<String> ids = [currentUserId, receiverEmail];
      // ids.sort();
      // String chatRoomId = ids.join("_");

      // add new message to database
      await _fireStore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(newMessage.toMap());
    }
  }

  Future<void> getAIMessage(String chatRoomId, String message) async {
    // get current user info
    print("Gettiing AI Message");
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();

    final Timestamp msg_timestamp = Timestamp.now();

    List<String> receiverEmail = chatRoomId.split('_');
    receiverEmail.remove(currentUserEmail);

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .get();

    List<Map<String, dynamic>> messages = [];
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      messages.add(doc.data() as Map<String, dynamic>);
    }

    List<Content>? history_cov = [];
    // Handle messages here
    for (Map<String, dynamic> messageData in messages) {
      // Access message data as needed
      if (messageData['senderEmail'] == currentUserEmail) {
        history_cov.add(Content.text(messageData['message']));
        print('User Message: ${messageData['message']}');
      } else {
        history_cov.add(Content.model([TextPart(messageData['message'])]));
        print('AI Message: ${messageData['message']}');
      }
    }

    print("history: ");
    print(history_cov);

    String? receivedMessage = "";

    const apiKey = String.fromEnvironment('API_KEY', defaultValue: '');
    // final apiKey = Platform.environment['API_KEY'];
    print('key: $apiKey');
    if (apiKey.isEmpty) {
      print('No \$API_KEY environment variable');
    } else {
      final model = GenerativeModel(
          model: 'gemini-pro',
          apiKey: apiKey,
          generationConfig: GenerationConfig());
      // Initialize the chat
      final chat = model.startChat(history: history_cov
          //   [
          //   Content.text('Hello, I have 2 dogs in my house.'),
          //   Content.model(
          //       [TextPart('Great to meet you. What would you like to know?')])
          // ]
          );
      var content = Content.text(message);
      var response = await chat.sendMessage(content);
      print("Feedback:");
      print(response.promptFeedback);
      receivedMessage = response.text;
      print("Received: ");
      print(receivedMessage);
    }

    if (receivedMessage == "") {
      receivedMessage = "Please offer extra information.";
    }
    Message newMessage = Message(
        message: message,
        senderEmail: currentUserEmail,
        receiverEmail: receiverEmail,
        timestamp: msg_timestamp);

    // construct chat room id from current user id and receiver id (sorted to ensure uniqueness)
    // List<String> ids = [currentUserId, receiverEmail];
    // ids.sort();
    // String chatRoomId = ids.join("_");

    // add new message to database
    await _fireStore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());

    if (receivedMessage == null) {
      return;
    }
    final Timestamp ai_msg_timestamp = Timestamp.now();
    // create a new message
    Message aiMessage = Message(
        message: receivedMessage,
        senderEmail: "ai",
        receiverEmail: [currentUserEmail],
        timestamp: ai_msg_timestamp);

    // construct chat room id from current user id and receiver id (sorted to ensure uniqueness)
    // List<String> ids = [currentUserId, receiverEmail];
    // ids.sort();
    // String chatRoomId = ids.join("_");

    // add new message to database
    await _fireStore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(aiMessage.toMap());
  }

  // get messages
  Stream<QuerySnapshot> getMessages(String chatRoomId) {
    // construct chat room id from user ids
    // List<String> ids = [userId, otherUserId];
    // ids.sort();
    // String chatRoomId = ids.join("_");

    return _fireStore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
