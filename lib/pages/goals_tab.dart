import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:keeping_fit/pages/set_goal_page.dart';

class GoalsTab extends StatefulWidget {
  final String docID;
  const GoalsTab({super.key, required this.docID});

  @override
  State<GoalsTab> createState() => _GoalsTabState();
}

class _GoalsTabState extends State<GoalsTab> {
  List<bool>? _isOpen;

  @override
  void initState() {
    // TODO: implement initState
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
                      fontSize: 25),
                ),
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SetGoalPage(
                                docID: widget.docID,
                              )),
                    );
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
          ),
          SizedBox(
            height: 10.0,
          ),
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
                          child: Text(
                        "Error: ${snapshot.error}",
                        style: TextStyle(color: Colors.white),
                      ));
                    } else if (snapshot.hasData) {
                      if (snapshot.data!.docs.isEmpty) {
                        return Center(
                            child: Text(
                          "No goals found",
                          style: TextStyle(color: Colors.white),
                        ));
                      }
                      if (_isOpen!.isEmpty) {
                        _isOpen = List.generate(snapshot.data!.docs.length,
                            (index) => (index == 0));
                      }
                      return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: ListView(children: [
                            ExpansionPanelList(
                              expansionCallback: (panelIndex, isExpanded) {
                                setState(() {
                                  _isOpen![panelIndex] = isExpanded;
                                });
                              },
                              children: snapshot.data!.docs
                                  .asMap()
                                  .entries
                                  .map<ExpansionPanel>((entry) {
                                int index = entry.key;
                                QueryDocumentSnapshot doc = entry.value;
                                return ExpansionPanel(
                                  backgroundColor:
                                      Color.fromARGB(255, 178, 173, 173),
                                  headerBuilder:
                                      (BuildContext context, bool isExpanded) {
                                    return ListTile(
                                      title: Text(doc['final'],
                                          style: TextStyle(
                                              color: Colors
                                                  .white)), // Replace with your document field
                                    );
                                  },
                                  body: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            'Details for ${doc['final']}', // Replace with your details
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ],
                                      )),
                                  isExpanded: _isOpen![index],
                                );
                              }).toList(),
                              // Replace with your document field
                              // Add other fields or widgets as needed
                            ),
                          ]));
                    } else {
                      return Center(child: Text("No data available"));
                    }
                  }))
        ],
      ),
    );
  }
}
