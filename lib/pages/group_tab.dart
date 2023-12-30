import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:keeping_fit/pages/add_friend_page.dart';
import 'package:keeping_fit/pages/chat_page.dart';

class GroupTab extends StatefulWidget {
  final String docID;
  const GroupTab({super.key, required this.docID});

  @override
  State<GroupTab> createState() => _GroupTabState();
}

class _GroupTabState extends State<GroupTab> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<DocumentSnapshot<Map<String, dynamic>>>? myData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myData = _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MY CHAT',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Rubik Doodle Shadow',
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              ),
              FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddFriendPage(
                              docID: widget.docID,
                            )),
                  );

                  if (result) {
                    setState(() {
                      myData = _fetchData();
                    });
                  }
                },
                backgroundColor: Color.fromARGB(255, 178, 173, 173),
                mini: true,
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          // _buildFriendList(),
        ),
        SizedBox(
          height: 10.0,
        ),
        _buildFriendList(),
      ]),
    );
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchData() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.docID)
        .get();
  }

  Widget _buildFriendList() {
    return FutureBuilder(
        future: myData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text(
              'Loading',
              style: TextStyle(color: Colors.white),
            );
          }

          if (snapshot.hasError) {
            return const Text(
              'Error',
              style: TextStyle(color: Colors.white),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Text(
                "No data available"); // Handle case where there's no data
          }
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;

          Map<String, String> friends = {};
          if (data['friends'] != null && data['friends'] is Map) {
            (data['friends'] as Map).forEach((key, value) {
              if (key is String && value is String) {
                friends[key] = value;
              }
            });
          }

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListView(
                children: friends.entries.map((entry) {
                  String email = entry.key;
                  String friend = entry.value;

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
            ),
          );
        });
  }
  // Widget _buildFriendList() {}

  // Widget _buildFriendListItem(DocumentSnapshot document) {
  //   Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

  // }
}
