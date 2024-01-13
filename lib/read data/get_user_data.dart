import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:keeping_fit/pages/goals_tab.dart';
import 'package:keeping_fit/pages/group_tab.dart';
import 'package:keeping_fit/pages/set_goal_page.dart';
import 'package:keeping_fit/pages/show_friends_page.dart';

class GetUserData extends StatefulWidget {
  final String docID;
  const GetUserData({super.key, required this.docID});

  @override
  State<GetUserData> createState() => _GetUserDataState();
}

class _GetUserDataState extends State<GetUserData>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  Future<DocumentSnapshot<Map<String, dynamic>>>? myData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    myData = _fetchData();
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>>? _fetchData() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.docID)
        .get();
  }

  void updateUserData() {
    setState(() {
      myData = _fetchData();
    });
  }

  int getFriendsCount(dynamic friendsData) {
    if (friendsData == null) {
      return 0; // Return 0 if friendsData is null
    } else if (friendsData is Map) {
      return friendsData.length;
    } else if (friendsData is List) {
      return friendsData.length;
    } else {
      return 0; // Handle other unexpected cases
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
        future: myData,
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            int friendsCount = getFriendsCount(data['friends']);
            return Scaffold(
                backgroundColor: Colors.grey.shade900,
                body: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.account_circle,
                                    size: 95,
                                    color: Color.fromARGB(255, 188, 218, 203),
                                  ),
                                  Text(
                                    data['usrname'].toString().toUpperCase(),
                                    style: TextStyle(
                                        fontFamily: 'Rubik Doodle Shadow',
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            '0',
                                            style: TextStyle(
                                                // fontFamily: 'Exo',
                                                fontSize: 20,
                                                color: Colors.white),
                                          ),
                                          Text(
                                            'Posts',
                                            style: TextStyle(
                                                // fontFamily: 'Exo',
                                                fontSize: 15,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            '0',
                                            style: TextStyle(
                                                // fontFamily: 'Exo',
                                                fontSize: 20,
                                                color: Colors.white),
                                          ),
                                          Text(
                                            'Followers',
                                            style: TextStyle(
                                                // fontFamily: 'Exo',
                                                fontSize: 15,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ShowFriendsPage(
                                                          docID:
                                                              widget.docID)));
                                        },
                                        child: Column(
                                          children: [
                                            Text(
                                              '$friendsCount',
                                              style: TextStyle(
                                                  // fontFamily: 'Exo',
                                                  fontSize: 20,
                                                  color: Colors.white),
                                            ),
                                            Text(
                                              'Following',
                                              style: TextStyle(
                                                  // fontFamily: 'Exo',
                                                  fontSize: 15,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.center,
                                //   children: [
                                //     Icon(
                                //       Icons.mail,
                                //       color: Colors.white,
                                //     ),
                                //     SizedBox(
                                //       width: 10,
                                //     ),
                                //     Text(
                                //       data['email'],
                                //       style: TextStyle(
                                //           // fontFamily: 'Exo',
                                //           fontSize: 15,
                                //           fontWeight: FontWeight.bold,
                                //           color: Colors.white),
                                //     ),
                                //   ],
                                // ),
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TabBar(
                            tabs: [
                              Tab(
                                  child: Icon(
                                Icons.flag,
                                color: Colors.white,
                                size: 30,
                              )),
                              Tab(
                                  child: Icon(
                                Icons.chat,
                                color: Colors.white,
                                size: 30,
                              )),
                              Tab(
                                  child: Icon(
                                Icons.emoji_events,
                                color: Colors.white,
                                size: 30,
                              ))
                            ],
                            controller: _tabController,
                            indicatorColor: Colors.yellow,
                            indicatorSize: TabBarIndicatorSize.tab,
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              GoalsTab(docID: widget.docID),
                              GroupTab(
                                docID: widget.docID,
                                updateParent: updateUserData,
                              ),
                              Center(
                                child: Text(
                                  'ACHIEVEMENT',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Rubik Doodle Shadow',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
          } else {
            return Text('Loading');
          }
        }));
  }
}
