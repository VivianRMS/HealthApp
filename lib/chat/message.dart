import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderEmail;
  final List<String> receiverEmail;
  final String message;
  final Timestamp timestamp;

  Message(
      {required this.senderEmail,
      required this.receiverEmail,
      required this.message,
      required this.timestamp});

  // conver to a map
  Map<String, dynamic> toMap() {
    return {
      'senderEmail': senderEmail,
      'receiverEmail': receiverEmail,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
