import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:keeping_fit/pages/set_goal_page.dart';

class GoalsTab extends StatefulWidget {
  final String docID;

  const GoalsTab({Key? key, required this.docID}) : super(key: key);

  @override
  _GoalsTabState createState() => _GoalsTabState();
}

class _GoalsTabState extends State<GoalsTab> {
  late List<bool> _isOpen;

  @override
  void initState() {
    super.initState();
    _isOpen = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'MY GOAL',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Rubik Doodle Shadow',
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SetGoalPage(docID: widget.docID),
                      ),
                    );
                  },
                  backgroundColor: Color.fromARGB(255, 178, 173, 173),
                  mini: true,
                  child: Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.0),
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.docID)
                  .collection('goal')
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("Error: ${snapshot.error}",
                        style: TextStyle(color: Colors.white)),
                  );
                } else if (snapshot.hasData) {
                  if (snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text("No goals found",
                          style: TextStyle(color: Colors.white)),
                    );
                  }

                  _isOpen = List.generate(
                      snapshot.data!.docs.length, (index) => false);

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: ListView(
                      children: [
                        ExpansionPanelList(
                          expansionCallback: (int index, bool isExpanded) {
                            setState(() {
                              _isOpen[index] = !isExpanded;
                            });
                          },
                          children: snapshot.data!.docs.map<ExpansionPanel>(
                              (QueryDocumentSnapshot document) {
                            Map<String, dynamic> data =
                                document.data() as Map<String, dynamic>;
                            String goalTitle = data['final'] ?? 'Unknown Goal';

                            return ExpansionPanel(
                              headerBuilder:
                                  (BuildContext context, bool isExpanded) {
                                return ListTile(
                                  title: Text(goalTitle,
                                      style: TextStyle(color: Colors.white)),
                                );
                              },
                              body: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'Details for $goalTitle',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              isExpanded: _isOpen[
                                  snapshot.data!.docs.indexOf(document)],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Center(child: Text("No data available"));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
