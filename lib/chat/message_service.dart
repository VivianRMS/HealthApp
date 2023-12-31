import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:keeping_fit/chat/message.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  // send message
  Future<void> sendMessage(String chatRoomId, String message) async {
    // get current user info
    final String currentUserId = _firebaseAuth.currentUser!.email.toString();
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();

    final Timestamp timestamp = Timestamp.now();

    List<String> receiverEmail = chatRoomId.split('_');

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
