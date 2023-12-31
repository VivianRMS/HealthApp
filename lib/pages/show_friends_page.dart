import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:keeping_fit/chat/chat_page.dart';

class ShowFriendsPage extends StatefulWidget {
  final String docID;
  const ShowFriendsPage({super.key, required this.docID});

  @override
  State<ShowFriendsPage> createState() => _ShowFriendsPageState();
}

class _ShowFriendsPageState extends State<ShowFriendsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 178, 173, 173),
        title: Text(
          'My Friends',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.grey.shade900,
      body: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.docID)
              .get(),
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            if (!snapshot.hasData ||
                snapshot.data == null ||
                !snapshot.data!.exists) {
              return Center(child: Text("No data available"));
            }

            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;

            Map<String, String> friends = {};
            if (data['friends'] != null && data['friends'] is Map) {
              data['friends'].forEach((key, value) {
                if (key is String && value is String) {
                  friends[key] = value;
                }
              });
            }

            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: ListView(
                children: friends.entries.map((entry) {
                  String email = entry.key;
                  String friend = entry.value;
                  List<String> ids = [widget.docID, email];
                  ids.sort();
                  String chatRoomId = ids.join("_");
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: ListTile(
                      title: Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: Color.fromARGB(255, 178, 173, 173),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            friend.toUpperCase(),
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Rubik Doodle Shadow',
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChatPage(
                                      receiverUserEmail: email,
                                      receiverUserID: friend,
                                    )));
                      },
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.white, width: 2.0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          })),
    );
  }
}
