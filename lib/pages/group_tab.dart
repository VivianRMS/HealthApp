import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:keeping_fit/pages/add_friend_page.dart';
import 'package:keeping_fit/pages/add_group_page.dart';
import 'package:keeping_fit/chat/chat_page.dart';

class GroupTab extends StatefulWidget {
  final String docID;
  final Function updateParent;
  const GroupTab({super.key, required this.docID, required this.updateParent});

  @override
  State<GroupTab> createState() => _GroupTabState();
}

class _GroupTabState extends State<GroupTab> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<DocumentSnapshot<Map<String, dynamic>>>? myData;

  @override
  void initState() {
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
                'MY GROUP',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Rubik Doodle Shadow',
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              ),
              PopupMenuButton(
                child: Container(
                  padding: EdgeInsets.all(8), // Add padding around the icon
                  decoration: BoxDecoration(
                    color: Color.fromARGB(
                        255, 178, 173, 173), // Background color of the button
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  child: Icon(Icons.add, color: Colors.white), // Icon color
                ),
                // icon: Icon(
                //   Icons.add,
                //   color: Colors.white,
                //   size: 20,
                // ),
                color: Color.fromARGB(255, 158, 154, 154),
                onSelected: (String option) async {
                  bool? result = true;
                  switch (option) {
                    case 'New Friend':
                      result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddFriendPage(
                                  docID: widget.docID,
                                )),
                      );
                      break;
                    case 'New Group':
                      result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddGroupPage(
                                  docID: widget.docID,
                                )),
                      );
                      break;
                  }
                  if (result != null && result == true) {
                    setState(() {
                      print('84');
                      myData = _fetchData();
                      widget.updateParent();
                    });
                  }
                  ;
                },
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'New Friend',
                    child: Text('Add Friend',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const PopupMenuItem<String>(
                    value: 'New Group',
                    child: Text('Add Group',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  // Add more items here for more choices
                ],
              )
              // FloatingActionButton(
              //   onPressed: () async {
              //     final result = await Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //           builder: (context) => AddFriendPage(
              //                 docID: widget.docID,
              //               )),
              //     );

              //     if (result != null && result == true) {
              //       setState(() {
              //         myData = _fetchData();
              //       });
              //     }
              //   },
              //   backgroundColor: Color.fromARGB(255, 178, 173, 173),
              //   mini: true,
              //   child: Icon(
              //     Icons.add,
              //     color: Colors.white,
              //     size: 20,
              //   ),
              // ),
            ],
          ),
          // _buildFriendList(),
        ),
        SizedBox(
          height: 10.0,
        ),
        _buildGroupList(),
      ]),
    );
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchData() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.docID)
        .get();
  }

  Widget _buildGroupList() {
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

          Map<String, String> groups = {};
          if (data['groups'] != null && data['groups'] is Map) {
            (data['groups'] as Map).forEach((key, value) {
              if (key is String && value is String) {
                groups[key] = value;
              }
            });
          }

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListView(
                children: groups.entries.map((entry) {
                  String email = entry.key;
                  String groupName = entry.value;

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
                            groupName.toUpperCase(),
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
                                      receiverUserID: groupName,
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
