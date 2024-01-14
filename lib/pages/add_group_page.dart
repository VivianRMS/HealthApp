import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class AddGroupPage extends StatefulWidget {
  final String docID;
  const AddGroupPage({super.key, required this.docID});

  @override
  State<AddGroupPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddGroupPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Map<String, String> _selectedEmail = {};

  final Map<String, String> friends = {};

  final _groupName = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _groupName.dispose();
  }

  Future addGroupDetails() async {
    List<String> _selected = _selectedEmail.entries.map((element) {
      return element.key as String;
    }).toList();
    _selected.add(widget.docID);
    _selected.sort();
    String newGroupEmail = _selected.join("_");
    Map<String, String> newGroup = {
      '$newGroupEmail': _groupName.text.isEmpty ? "CHAT" : _groupName.text
    };
    _selected.forEach((userId) async {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set({'groups': newGroup}, SetOptions(merge: true));
    });
  }

  Future<Map<String, String>> getFriends() async {
    try {
      var currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.docID)
          .get();

      if (currentUserDoc.exists && currentUserDoc.data() != null) {
        Map<String, dynamic> data =
            currentUserDoc.data() as Map<String, dynamic>;
        if (data['friends'] != null && data['friends'] is Map) {
          (data['friends'] as Map).forEach((key, value) {
            if (key is String && value is String) {
              friends[key] = value;
            }
          });
          return friends;
        }
      }
      return {}; // Return an empty set if the document or 'friends' field doesn't exist
    } catch (e) {
      print('Error fetching friends: $e');
      return {}; // Return an empty set in case of an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 178, 173, 173),
        // title: Text(
        //   'SET NEW GOAL',
        //   style: TextStyle(fontWeight: FontWeight.bold),
        // ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.group_add,
                size: 100,
                color: Color.fromARGB(255, 178, 173, 173),
              ),
              Text(
                'New Group!',
                style: TextStyle(
                    fontFamily: 'Rubik Doodle Shadow',
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(
                height: 10.0,
              ),
              FutureBuilder(
                  future: getFriends(),
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

                    return _buildFriendList(snapshot.data!);
                  }),
              Padding(
                padding: const EdgeInsets.fromLTRB(28.0, 10.0, 88.0, 10.0),
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  controller: _groupName,
                  decoration: InputDecoration(
                    hintText: 'GROUP NAME',
                    hintStyle: TextStyle(
                      color: Colors.white,
                    ),
                    fillColor: Color.fromARGB(255, 47, 46, 46),
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.black)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (!_selectedEmail.isEmpty && _selectedEmail.length >= 2)
            await addGroupDetails();

          Navigator.pop(
              context, (!_selectedEmail.isEmpty && _selectedEmail.length >= 2));
        },
        child: Icon(Icons.check_box),
      ),
    );
  }

  Widget _buildFriendList(Map<String, String> friends) {
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
                    setState(() {
                      if (_selectedEmail.containsKey(email)) {
                        _selectedEmail.remove(email);
                      } else {
                        _selectedEmail[email] = friend;
                      }
                    });
                  },
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: _selectedEmail.containsKey(email)
                            ? Colors.yellow
                            : Colors.white,
                        width: 2.0),
                    borderRadius: BorderRadius.circular(4),
                  )),
            );
          }).toList(),
        ),
      ),
    );
  }
}
