import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:keeping_fit/goal/sleepTemplate.dart';
import 'package:keeping_fit/goal/foodTemplate.dart';
import 'package:keeping_fit/goal/sportsTemplate.dart';

class SetGoalPage extends StatefulWidget {
  final String docID;
  const SetGoalPage({super.key, required this.docID});

  @override
  State<SetGoalPage> createState() => _SetGoalPageState();
}

class _SetGoalPageState extends State<SetGoalPage> {
  // final _finalController = TextEditingController();
  // final _periodCondroller = TextEditingController();
  String mainType = 'sports';
  String? subType;

  List<String> mainTypes = ['sports', 'food', 'sleep'];
  List<String> subTypes = ['lose weight', 'muscle building'];
  // Map<String, List<String>> subTypes = {
  //   'sleep': [],
  //   'sports': ['lose weight', 'muscle building'],
  //   'food': ['lose weight', 'muscle building'],
  // };

  @override
  void dispose() {
    super.dispose();
  }

  Future<String> addGoalDetails(String mainType, String? subType) async {
    String goalType = subType != null ? '$mainType - $subType' : mainType;
    print(subType);
    DocumentReference docRef = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.docID)
        .collection('goal')
        .add({
      'type': goalType,
    });
    return docRef.id;
  }

  @override
  Widget build(BuildContext context) {
    // List<String>? currentSubTypes = subTypes[mainType];
    bool shouldShowSubType = mainType == 'sports' || mainType == 'food';
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(178, 173, 173, 1),
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
                Icons.flag,
                size: 100,
                color: Color.fromARGB(255, 178, 173, 173),
              ),
              Text(
                'Choose goal type',
                style: TextStyle(
                    fontFamily: 'Rubik Doodle Shadow',
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: DropdownButtonFormField<String>(
                  value: mainType,
                  items:
                      mainTypes.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      mainType = newValue!;
                      // currentSubTypes = subTypes[mainType];
                      // subType = currentSubTypes?.first;
                      shouldShowSubType =
                          mainType == 'sports' || mainType == 'food';
                      print("100 " + mainType);
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(255, 47, 46, 46),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 31, 30, 30)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.white), // 设置获得焦点时的边框颜色为白色
                    ),
                  ),
                  dropdownColor: Color.fromARGB(255, 47, 46, 46),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              if (shouldShowSubType)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: DropdownButtonFormField<String>(
                    value: subType,
                    items:
                        subTypes.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        subType = newValue;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color.fromARGB(255, 47, 46, 46),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Color.fromARGB(255, 31, 30, 30)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.white), // 设置获得焦点时的边框颜色为白色
                      ),
                    ),
                    dropdownColor: Color.fromARGB(255, 47, 46, 46),
                    style: TextStyle(color: Colors.white),
                  ),
                )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String goalID = await addGoalDetails(mainType, subType);
          // Navigator.pop(context);
          if (mainType == 'sleep') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => sleepTemplatePage(
                        docID: widget.docID,
                        goalID: goalID,
                      )),
            );
          } else if (mainType == 'sports') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => sportsTemplatePage(
                        docID: widget.docID,
                        goalID: goalID,
                      )),
            );
          } else if (mainType == 'food') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FoodTemplatePage(
                        docID: widget.docID,
                        goalID: goalID,
                      )),
            );
          }
        },
        child: Icon(Icons.check_box),
      ),
    );
  }
}
