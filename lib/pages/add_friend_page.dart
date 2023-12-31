import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class AddFriendPage extends StatefulWidget {
  final String docID;
  const AddFriendPage({super.key, required this.docID});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Map<String, String> _selectedEmail = {};

  final Map<String, String> friends = {};

  Future addFriendDetails() async {
    for (var entry in _selectedEmail.entries) {
      String email = entry.key;
      // Create a new map from _selectedEmail excluding the current element
      Map<String, String> newFriends = Map.from(_selectedEmail)..remove(email);
      print(newFriends);

      // Update the Firestore document for the current element
      await FirebaseFirestore.instance.collection('users').doc(email).set({
        'friends': newFriends,
      }, SetOptions(merge: true));
    }
  }

  Future<Map<String, String>> getNewFriends() async {
    try {
      var currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.docID)
          .get();

      if (currentUserDoc.exists && currentUserDoc.data() != null) {
        Map<String, dynamic> data =
            currentUserDoc.data() as Map<String, dynamic>;
        _selectedEmail[widget.docID] = data['usrname'];
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
                'New Friend!',
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
                  future: getNewFriends(),
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

                    return _buildUserList(snapshot.data!);
                  })
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          print(_selectedEmail);
          if (!_selectedEmail.isEmpty && _selectedEmail.length > 1)
            await addFriendDetails();

          Navigator.pop(
              context, (!_selectedEmail.isEmpty && _selectedEmail.length > 1));
        },
        child: Icon(Icons.check_box),
      ),
    );
  }

  Widget _buildUserList(Map<String, String> friends) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: ((context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Error');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Loading');
          }

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListView(
                children: snapshot.data!.docs
                    .map<Widget>((doc) => _buildUserListItem(doc, friends))
                    .toList(),
              ),
            ),
          );
        }));
  }

  Widget _buildUserListItem(
      DocumentSnapshot documentSnapshot, Map<String, String> friends) {
    Map<String, dynamic> data =
        documentSnapshot.data()! as Map<String, dynamic>;

    if (_auth.currentUser!.email != data['email'] &&
        !friends.containsKey(data['email'])) {
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
                  data['usrname'].toString().toUpperCase(),
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
                if (_selectedEmail.containsKey(data['email'])) {
                  _selectedEmail.remove(data['email']);
                } else {
                  _selectedEmail[data['email']] = data['usrname'];
                }
              });
            },
            // tileColor: _selectedEmail.contains(data['email'])
            //     ? Colors.yellow
            //     : Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: _selectedEmail.containsKey(data['email'])
                      ? Colors.yellow
                      : Colors.white,
                  width: 2.0),
              borderRadius: BorderRadius.circular(4),
            )),
      );
    } else {
      return Container();
    }
  }
}
