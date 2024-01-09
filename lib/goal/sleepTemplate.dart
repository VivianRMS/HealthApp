import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

class sleepTemplatePage extends StatefulWidget {
  final String docID;
  final String goalID;
  const sleepTemplatePage(
      {super.key, required this.docID, required this.goalID});

  @override
  State<sleepTemplatePage> createState() => _sleepTemplatePageState();
}

class PlanDetails {
  String planContext;
  DateTime whenToEnd;
  int mintimes;
  int complete;
  String selectionOption;
  int goalduration;
  int completegoalduration = 0;
  int? cal;
  bool isSaved;
  String? docID;
  TextEditingController dateController;
  bool win;

  PlanDetails({
    this.planContext = '',
    required this.whenToEnd,
    this.mintimes = 0,
    this.complete = 0,
    this.selectionOption = 'frequency',
    this.goalduration = 0,
    this.completegoalduration = 0,
    this.cal,
    this.isSaved = false,
    this.docID,
    this.win = false,
  }) : dateController = TextEditingController(
            text: DateFormat('yyyy-MM-dd').format(whenToEnd));

  Map<String, dynamic> toMap() {
    return {
      'planContext': planContext,
      'whenToEnd': whenToEnd,
      'minimumCompletion': mintimes,
      'complete': complete,
      'select': selectionOption,
      'duration': goalduration,
      'completeduration': completegoalduration,
      'cal':cal,
      'win': win,
    };
  }
}


class _sleepTemplatePageState extends State<sleepTemplatePage> {
  final _goalNameController = TextEditingController();
  List<PlanDetails> plans = [];

  @override
  void dispose() {
    _goalNameController.dispose();
    super.dispose();
  }

  
  void addPlan() {
    setState(() {
      plans.add(PlanDetails(whenToEnd: DateTime.now()));
    });
  }

  Future addGoal() async {
    String goalName = _goalNameController.text;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.docID)
        .collection('goal')
        .doc(widget.goalID)
        .set({
      'goalName': goalName,
    }, SetOptions(merge: true));
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

///////////////////////////////////////

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

  Widget _buildNumberPicker(PlanDetails plan) {
    int tempMintimes = plan.mintimes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 28.0, top: 8.0, bottom: 8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Minimum completions',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 75,
                padding: EdgeInsets.symmetric(horizontal: 28.0), // 添加左边距
                child: CupertinoPicker(
                  itemExtent: 32.0,
                  backgroundColor: Colors.transparent,
                  onSelectedItemChanged: (int selectedIndex) {
                    setState(() {
                      tempMintimes = selectedIndex;
                      // print(tempMintimes);
                      plan.isSaved = false;
                      plan.mintimes = tempMintimes;
                    });
                  },
                  children: List<Widget>.generate(100, (index) {
                    return Center(
                      child: Text(
                        index.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }),
                  scrollController:
                      FixedExtentScrollController(initialItem: plan.mintimes),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.download_done, color: Colors.green),
              onPressed: () {
                setState(() {
                  if (plan.isSaved) {
                    plan.isSaved = false;
                  }
                  // print(plan.mintimes);
                  // print(tempMintimes);
                  plan.mintimes = tempMintimes;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

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
              _buildNumberPicker(plan),
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
        title: Text(
          'Set Sleep Goal',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 158, 49, 178),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bed_outlined,
                  size: 80,
                  color: Color.fromARGB(255, 197, 206, 201),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: _goalNameController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Goal Name',
                      hintStyle: TextStyle(
                        color: Colors.white,
                      ),
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
                for (var plan in plans) ...[
                  _buildPlanCard(plan),
                ],
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
