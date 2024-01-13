import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:keeping_fit/goal/sleepTemplate.dart';

class SportsEdit extends StatefulWidget {
  final String docID;
  final String goalID;
  const SportsEdit({super.key, required this.docID, required this.goalID});

  @override
  State<SportsEdit> createState() => _SportsEditState();
}

class _SportsEditState extends State<SportsEdit> {
  final _goalNameController = TextEditingController();
  final _nowweightController = TextEditingController();
  final _goalweightController = TextEditingController();
  final _durationController = TextEditingController();

  List<PlanDetails> plans = [];

  @override
  void initState() {
    super.initState();
    loadGoalAndPlans();
  }

  @override
  void dispose() {
    _goalNameController.dispose();
    _nowweightController.dispose();
    _goalweightController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void loadGoalAndPlans() async {
    var goalDocument = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.docID)
        .collection('goal')
        .doc(widget.goalID)
        .get();
    _goalNameController.text = goalDocument['goalName'];
    _nowweightController.text = goalDocument['Weight'];
    _goalweightController.text = goalDocument['your goal'];
    // print(goalDocument['goalName']);

    var planDocument = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.docID)
        .collection('goal')
        .doc(widget.goalID)
        .collection('plans')
        .get();
    

    setState(() {
      plans = planDocument.docs.map((doc) {
        var planData = doc.data();
        // print(planData['planContext']);
        // _durationController.text = planData['duration'];
        return PlanDetails(
          planContext: planData['planContext'],
          whenToEnd: (planData['whenToEnd'] as Timestamp).toDate(),
          mintimes: planData['minimumCompletion'],
          complete: planData['complete'],
          selectionOption: planData['select'],
          goalduration: planData['duration'],
          completegoalduration: planData['completeduration'],
          win:planData['win'],
          isSaved: true,
          docID: doc.id,
        );
      }).toList();
    });
  }

  void savePlans() async {
    // String goalId = await addGoal(); // 保留这一行创建新的目标
    for (var plan in plans) {
      if (plan.isSaved) continue;
      var planData = plan.toMap();
      if (plan.docID != null) {
        // 如果存在 docID，更新现有的文档
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.docID)
            .collection('goal')
            .doc(widget.goalID)
            .collection('plans')
            .doc(plan.docID)
            .update(planData);
      } else {
        // 如果不存在 docID，创建新的文档
        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.docID)
            .collection('goal')
            .doc(widget.goalID)
            .collection('plans')
            .add(planData);
        plan.docID = docRef.id; // 存储新创建的文档 ID
      }
    }

    setState(() {
      for (var plan in plans) {
        plan.isSaved = true;
      }
    });

    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text('Goal and plans saved successfully'),
    //     duration: Duration(seconds: 2),
    //   ),
    // );
  }

  void addPlan() {
    setState(() {
      plans.add(PlanDetails(whenToEnd: DateTime.now()));
    });
  }

  Future addGoal() async {
    String goalName = _goalNameController.text;
    String nowWeight = _nowweightController.text;
    String goalweight = _goalweightController.text;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.docID)
        .collection('goal')
        .doc(widget.goalID)
        .set({
      'goalName': goalName,
      'Weight': nowWeight,
      'your goal': goalweight,
    }, SetOptions(merge: true));
  }

  @override
  Widget _buildTextField(TextEditingController controller, String hintText,
      {Function(String)? onChanged, required PlanDetails plan}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0),
      child: TextField(
        controller: controller,
        onChanged: (value) {
          if (onChanged != null) {
            onChanged(value);
          }
          if (plan.isSaved) {
            setState(() {
              plan.isSaved = false;
            });
          }
        },
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: hintText,
          labelStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(),
          fillColor: Color.fromARGB(255, 106, 105, 105),
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color.fromARGB(255, 31, 30, 30)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget _buildDateField(PlanDetails plan) {
    TextEditingController datacontroller = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(plan.whenToEnd));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0),
      child: TextFormField(
        controller: datacontroller,
        decoration: InputDecoration(
          icon: Icon(Icons.calendar_today,
              color: Color.fromARGB(255, 178, 173, 173)),
          hintText: "When to End",
          hintStyle: TextStyle(color: Colors.white),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        readOnly: true,
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: plan.whenToEnd ?? DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2040, 12, 31),
          );
          if (pickedDate != null) {
            setState(() {
              plan.whenToEnd = pickedDate;
              datacontroller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
              plan.isSaved = false;
            });
          }
        },
      ),
    );
  }

  Widget _FrequencyandDuration(PlanDetails plan) {
    TextEditingController durationController =
        TextEditingController(text: plan.goalduration.toString());

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Card(
              margin: EdgeInsets.all(8.0),
              // color: Colors.grey,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    plan.selectionOption = 'frequency';
                  });
                },
                child: Text('Frequency'),
                
                // style: TextButton.styleFrom(
                //   primary: plan.selectionOption == 'frequency' ? Colors.grey: Colors.white,
                // ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: plan.selectionOption == 'frequency' ? Color.fromARGB(255, 146, 214, 239) : const Color.fromARGB(255, 197, 202, 233),
                  width: 4,
                ),
              ),
            ),
            Card(
              margin: EdgeInsets.all(8.0),
              // color: Colors.indigo[100],
              child: TextButton(
                onPressed: () {
                  setState(() {
                    plan.selectionOption = 'duration';
                  });
                },
                child: Text('Duration'),
                // style: TextButton.styleFrom(
                //   primary: plan.selectionOption == 'frequency' ? Colors.grey: Colors.white,
                // ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: plan.selectionOption == 'duration' ? Color.fromARGB(255, 146, 214, 239) : const Color.fromARGB(255, 197, 202, 233),
                  width: 4,
                ),
              ),
            ),
          ],
        ),
        if(plan.selectionOption == 'frequency')
          Container(
            height: 75,
            padding: EdgeInsets.symmetric(horizontal: 50.0),
            child: CupertinoPicker(
              itemExtent: 32,
              backgroundColor: Colors.transparent,
              onSelectedItemChanged: (int selectedIndex){
                setState(() {
                  plan.mintimes = selectedIndex;
                  plan.isSaved = false;
                });
              },
              children: List<Widget>.generate(100, (index){
                return Center(
                  child: Text(
                    index.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }),
            scrollController: FixedExtentScrollController(initialItem: plan.mintimes),
          ),
        ),
        if(plan.selectionOption == 'duration')
          Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: TextField(
            controller: _durationController,
            onChanged: (value) {
              int? duration = int.tryParse(value);
              if (duration != null && duration >= 0 && duration <= 300) {
                setState(() {
                  plan.goalduration = duration;
                  plan.isSaved = false;
                });
              }
            },
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter Duration (0-300 min)",
              hintStyle: TextStyle(color: Colors.white),
              fillColor: Color.fromARGB(255, 106, 105, 105),
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color.fromARGB(255, 31, 30, 30)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget _buildPlanCard(PlanDetails plan) {
    TextEditingController planContextController =
        TextEditingController(text: plan.planContext);
    
    return Padding(
      key: ObjectKey(plan),
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Card(
        margin: EdgeInsets.all(8.0),
        color: Colors.indigo[100],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 15.0),
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      planContextController,
                      'Plan Context',
                      onChanged: (value) => plan.planContext = value,
                      plan: plan,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete,
                        color: const Color.fromARGB(255, 103, 100, 100)),
                    onPressed: () {
                      setState(() {
                        plans.remove(plan);
                      });
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
              _buildDateField(plan),
              SizedBox(
                height: 10.0,
              ),
               _FrequencyandDuration(plan),
              SizedBox(
                height: 10.0,
              ),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: plan.isSaved ? Colors.white : Colors.red,
            width: 2,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: Text('Edit Goal'),
        backgroundColor: Colors.grey,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.0),
            child: Center(
              child: Column(children: [
                Icon(
                  Icons.sports,
                  size: 80,
                  color: Color.fromARGB(255, 197, 206, 201),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: _goalNameController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Goal Name',
                      labelStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(),
                      fillColor: Color.fromARGB(255, 47, 46, 46),
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 31, 30, 30))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white)),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 160,
                        child: TextField(
                          controller: _nowweightController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            suffixText: 'kg',
                            suffixStyle: TextStyle(color: Colors.white),
                            labelText: 'Weight(kg)',
                            labelStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(),
                            fillColor: Color.fromARGB(255, 47, 46, 46),
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 31, 30, 30))),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white)),
                          ),
                        ),
                      ),
                      SizedBox(width: 30),
                      Container(
                        width: 160,
                        child: TextField(
                          controller: _goalweightController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            suffixText: 'kg',
                            suffixStyle: TextStyle(color: Colors.white),
                            labelText: 'Goal Weight(kg)',
                            labelStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(),
                            fillColor: Color.fromARGB(255, 47, 46, 46),
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 31, 30, 30))),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: plans.length,
                  itemBuilder: (context, index) {
                    return _buildPlanCard(plans[index]);
                  },
                ),
                ElevatedButton(
                  onPressed: addPlan,
                  child: Icon(Icons.add),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() async {
                      await addGoal();
                      savePlans();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Plan saved successfully'), // 修正这里，使用 'content' 而不是 'context'
                          duration: Duration(seconds: 2),
                        ),
                      );
                    });
                  },
                  child: Text('Save Plan'),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
