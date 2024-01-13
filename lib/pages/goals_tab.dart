import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keeping_fit/goal/food_edit.dart';
import 'package:keeping_fit/goal/foodpunch.dart';
import 'package:keeping_fit/goal/sleepTemplate.dart';
import 'package:keeping_fit/goal/sleep_edit.dart';
import 'package:keeping_fit/pages/set_goal_page.dart';

import '../goal/sports_edit.dart';

class GoalsTab extends StatefulWidget {
  final String docID;
  const GoalsTab({super.key, required this.docID});

  @override
  State<GoalsTab> createState() => _GoalsTabState();
}

class _GoalsTabState extends State<GoalsTab> {
  List<bool>? _isOpen;
  Future<QuerySnapshot>? _goalsFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshGoals();
    _isOpen = [];
  }

  void refreshGoals() async {
    setState(() {
      // 使用新的Future来强制FutureBuilder重新获取数据
      _goalsFuture = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.docID)
          .collection('goal')
          .get();
    });
  }

// delete plan
  Future<void> deletePlanFromFirebase(
      DocumentSnapshot doc, String planId) async {
    await doc.reference.collection('plans').doc(planId).delete();
    refreshGoals();
  }

// delete goal and plan
  Future<void> deleteGoal(DocumentSnapshot goalDoc) async {
    QuerySnapshot planSnapshot =
        await goalDoc.reference.collection('plans').get();
    for (DocumentSnapshot planDoc in planSnapshot.docs) {
      await planDoc.reference.delete();
    }
    await goalDoc.reference.delete();
    refreshGoals();
  }

// create goal name and delete
  Widget createListTile(BuildContext context, QueryDocumentSnapshot doc) {
    return ListTile(
      title: Row(
        children: [
          IconButton(
            onPressed: () async {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirm delete'),
                      content: Text(
                          'Are you sure to delete this goal including all plans under it'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            deleteGoal(doc);
                            Navigator.of(context).pop();
                          },
                          child: Text('Delete'),
                        ),
                      ],
                    );
                  });
            },
            icon: Icon(Icons.delete),
          ),
          Expanded(
            child: Text(
              doc['goalName'],
              style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Rainbow',
                  fontSize: 28.0),
            ),
          ),
        ],
      ),
    );
  }

// clock in
  Future<void> DurationPunch(
      BuildContext context, DocumentSnapshot planDoc) async {
    TextEditingController numberController = TextEditingController();
    bool confirmed = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm Clock In'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Enter the time you want to clock in:'),
                  TextField(
                    controller: numberController,
                    keyboardType: TextInputType.number,
                  )
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Confirm'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmed) {
      int numberToAdd = int.tryParse(numberController.text) ?? 0;
      await planDoc.reference
          .update({'completeduration': FieldValue.increment(numberToAdd)});

      DocumentSnapshot updatePlanDoc = await planDoc.reference.get();
      Map<String, dynamic> updatedData =
          updatePlanDoc.data() as Map<String, dynamic>;
      if (updatedData['completeduration'] >= updatedData['duration']) {
        await planDoc.reference.update({'win': true});
      } else {
        await planDoc.reference.update({'win': false});
      }

      refreshGoals();
    }
  }

  Future<void> SleepPunchPlan(
      BuildContext context, DocumentSnapshot planDoc) async {
    bool confirmed = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm Clock In'),
              content: Text('Do you want to clock in this plan?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Confirm'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmed) {
      await planDoc.reference.update({'complete': FieldValue.increment(1)});

      DocumentSnapshot updatePlanDoc = await planDoc.reference.get();
      Map<String, dynamic> updatedData =
          updatePlanDoc.data() as Map<String, dynamic>;
      if (updatedData['complete'] >= updatedData['minimumCompletion']) {
        await planDoc.reference.update({'win': true});
      } else {
        await planDoc.reference.update({'win': false});
      }

      refreshGoals();
    }
  }

// plan context
  Widget createPlanContext(
      BuildContext context,
      QueryDocumentSnapshot doc,
      Map<String, dynamic> plansData,
      String docID,
      DocumentSnapshot planDoc,
      String goalID) {
    return Row(
      children: [
        Expanded(
          child: Text(
            plansData['planContext'] ?? 'No Context',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
          ),
        ),
        IconButton(
          onPressed: () {
            if (doc['type'] == 'sleep') {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        SleepEdit(docID: docID, goalID: goalID)),
              ).then((_) => refreshGoals());
            } else if (doc['type'] == "sports - lose weight" ||
                doc['type'] == "sports - muscle building") {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        SportsEdit(docID: docID, goalID: goalID)),
              ).then((_) => refreshGoals());
            } else {
              //TODO food_edit
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        FoodEdit(docID: docID, goalID: goalID)),
              ).then((_) => refreshGoals());
            }
          },
          icon: Icon(Icons.edit),
        ),
        IconButton(
          onPressed: () async {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Confirm Delete"),
                  content: Text('Are you sure you want to delete this plan'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      child: Text("Delete"),
                      onPressed: () {
                        deletePlanFromFirebase(doc, planDoc.id);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          icon: Icon(Icons.delete),
        ),
      ],
    );
  }

// No plan exist
  Widget noPlanWidget(BuildContext context, QueryDocumentSnapshot doc,
      String docID, String goalID) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'No plan exists',
            style: TextStyle(color: Colors.white, fontSize: 20.0),
          ),
          IconButton(
            onPressed: () {
              if (doc['type'] == 'sleep') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SleepEdit(docID: docID, goalID: goalID)),
                ).then((_) => refreshGoals());
              } else if (doc['type'] == "sports - lose weight" ||
                  doc['type'] == "sports - muscle building") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SportsEdit(docID: docID, goalID: goalID)),
                ).then((_) => refreshGoals());
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          FoodEdit(docID: docID, goalID: goalID)),
                ).then((_) => refreshGoals());
              }
            },
            icon: Icon(Icons.edit),
          ),
        ],
      ),
    );
  }

// plan card
  @override
  ExpansionPanel createSleep(QueryDocumentSnapshot doc, int index) {
    return ExpansionPanel(
      backgroundColor: Color.fromARGB(179, 239, 219, 236),
      headerBuilder: (BuildContext context, bool isExpanded) {
        return createListTile(context, doc);
      },
      body: FutureBuilder<QuerySnapshot>(
        future: doc.reference.collection('plans').get(),
        builder: (context, PlansSnapshot) {
          if (PlansSnapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (PlansSnapshot.hasData && PlansSnapshot.data!.docs.isNotEmpty) {
            return Column(
              children: PlansSnapshot.data!.docs.map((planDoc) {
                Map<String, dynamic> plansData =
                    planDoc.data() as Map<String, dynamic>;
                return GestureDetector(
                  onTap: () async {
                    await SleepPunchPlan(context, planDoc);
                  },
                  child: Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(136, 239, 205, 221),
                      border: Border.all(color: Colors.grey, width: 2.0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      title: createPlanContext(context, doc, plansData,
                          widget.docID, planDoc, doc.id),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Plan Times: ${plansData['minimumCompletion'].toString()},Completed Times:${plansData['complete'].toString()}'),
                          Text(
                              'due date: ${DateFormat('yyyy-MM-dd').format(plansData['whenToEnd'].toDate())}'),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }
          return noPlanWidget(context, doc, widget.docID, doc.id);
        },
      ),
      isExpanded: _isOpen![index],
    );
  }

  @override
  ExpansionPanel createSports(QueryDocumentSnapshot doc, int index) {
    return ExpansionPanel(
      backgroundColor: Color.fromARGB(179, 239, 219, 236),
      headerBuilder: (BuildContext context, bool isExpanded) {
        return createListTile(context, doc);
      },
      body: FutureBuilder<QuerySnapshot>(
        future: doc.reference.collection('plans').get(),
        builder: (context, PlansSnapshot) {
          if (PlansSnapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (PlansSnapshot.hasData && PlansSnapshot.data!.docs.isNotEmpty) {
            return Column(
              children: PlansSnapshot.data!.docs.map((planDoc) {
                Map<String, dynamic> plansData =
                    planDoc.data() as Map<String, dynamic>;
                // print(plansData['select']);
                if (plansData['select'] == 'frequency') {
                  return GestureDetector(
                    onTap: () async {
                      await SleepPunchPlan(context, planDoc);
                    },
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(136, 239, 205, 221),
                        border: Border.all(color: Colors.grey, width: 2.0),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        title: createPlanContext(context, doc, plansData,
                            widget.docID, planDoc, doc.id),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Plan Times: ${plansData['minimumCompletion'].toString()},Completed Times:${plansData['complete'].toString()}'),
                            Text(
                                'due date: ${DateFormat('yyyy-MM-dd').format(plansData['whenToEnd'].toDate())}'),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return GestureDetector(
                    onTap: () async {
                      await DurationPunch(context, planDoc);
                    },
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(136, 239, 205, 221),
                        border: Border.all(color: Colors.grey, width: 2.0),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        title: createPlanContext(context, doc, plansData,
                            widget.docID, planDoc, doc.id),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Goal Duration: ${plansData['duration'].toString()},Completed:${plansData['completeduration'].toString()}'),
                            Text(
                                'due date: ${DateFormat('yyyy-MM-dd').format(plansData['whenToEnd'].toDate())}'),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              }).toList(),
            );
          }
          return noPlanWidget(context, doc, widget.docID, doc.id);
        },
      ),
      isExpanded: _isOpen![index],
    );
  }

  @override
  ExpansionPanel createFood(QueryDocumentSnapshot doc, int index) {
    return ExpansionPanel(
      backgroundColor: Color.fromARGB(179, 239, 219, 236),
      headerBuilder: (BuildContext context, bool isExpanded) {
        return createListTile(context, doc);
      },
      body: FutureBuilder<QuerySnapshot>(
        future: doc.reference.collection('plans').get(),
        builder: (context, PlansSnapshot) {
          if (PlansSnapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (PlansSnapshot.hasData && PlansSnapshot.data!.docs.isNotEmpty) {
            return Column(
              children: PlansSnapshot.data!.docs.map((planDoc) {
                Map<String, dynamic> plansData =
                    planDoc.data() as Map<String, dynamic>;
                String planID = planDoc.id;
                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FoodPunch(
                              plansData: plansData,
                              docID: widget.docID,
                              goalID: doc.id,
                              planID: planID)),
                    );
                  },
                  child: Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(136, 239, 205, 221),
                      border: Border.all(color: Colors.grey, width: 2.0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      title: createPlanContext(context, doc, plansData,
                          widget.docID, planDoc, doc.id),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Maximum daily calorie:${plansData['cal'].toString()}',
                            style: TextStyle(
                                color: const Color.fromARGB(255, 26, 101, 162),
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                              'Plan Times: ${plansData['minimumCompletion'].toString()},Completed Times:${plansData['complete'].toString()}'),
                          Text(
                              'due date: ${DateFormat('yyyy-MM-dd').format(plansData['whenToEnd'].toDate())}'),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }
          return noPlanWidget(context, doc, widget.docID, doc.id);
        },
      ),
      isExpanded: _isOpen![index],
    );
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
                // FloatingActionButton(
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(builder: (context))
                //     ).then((_) {
                //       refreshGoals();
                //     });
                //   },
                //   backgroundColor: Color.fromARGB(255, 197, 181, 200),
                //   mini: true,
                //   child: Icon(
                //     Icons.workspace_premium,
                //     color: Colors.white,
                //     size: 20,
                //   ),
                // ),
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SetGoalPage(
                                docID: widget.docID,
                              )),
                    ).then((_) {
                      refreshGoals();
                    });
                  },
                  backgroundColor: Color.fromARGB(255, 197, 181, 200),
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
                  future: _goalsFuture,
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
                      snapshot.data!.docs.forEach((thisdoc) async {
                        if (thisdoc['goalName'] == null ||
                            thisdoc['goalName'].isEmpty) {
                          await deleteGoal(thisdoc);
                        }
                      });
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
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
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
                                //print(doc['type']);
                                if (doc['type'] == "sleep") {
                                  return createSleep(doc, index);
                                } else if (doc['type'] ==
                                        "sports - lose weight" ||
                                    doc['type'] == "sports - muscle building") {
                                  return createSports(doc, index);
                                } else {
                                  return createFood(doc, index);
                                }
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
