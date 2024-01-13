import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:table_calendar/table_calendar.dart';

class FoodPunch extends StatefulWidget {
  final Map<String, dynamic> plansData;
  final String docID;
  final String goalID;
  final String planID;
  const FoodPunch(
      {super.key,
      required this.plansData,
      required this.docID,
      required this.goalID,
      required this.planID});

  @override
  State<FoodPunch> createState() => _FoodPunchState();
}

class _FoodPunchState extends State<FoodPunch> {
  Map<DateTime, bool?> CheckInData = {};
  Map<DateTime, List<String>?> memoData = {};
  // Map<DateTime, List<TextEditingController>> memoControllers = {};
  DateTime? focusedDay;
  DateTime? selectedDay;

  @override
  void initState() {
    super.initState();
    focusedDay = DateTime.now();
    selectedDay = null;
    _loadCheckInDate();
    _loadMemoData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadMemoData() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.docID)
        .collection('goal')
        .doc(widget.goalID)
        .collection('plans')
        .doc(widget.planID)
        .collection('date')
        .get();

    Map<DateTime, List<String>?> MData = {};
    for (var doc in snapshot.docs) {
      DateTime date = DateTime.parse(doc.id);
      List<String> memos = List<String>.from(doc.data()['memo'] ?? []);
      MData[date] = memos;
    }

    setState(() {
      memoData = MData;
      // _initMemoControllers();
    });
  }

  Future<void> _loadCheckInDate() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.docID)
        .collection('goal')
        .doc(widget.goalID)
        .collection('plans')
        .doc(widget.planID)
        .collection('date')
        .get();
    Map<DateTime, bool?> loadData = {};
    for (var doc in snapshot.docs) {
      loadData[DateTime.parse(doc.id)] = doc.data()['checked'] as bool?;
    }

    setState(() {
      CheckInData = loadData;
    });
  }

  Future<void> _ClockIn(DateTime selectedDay, DateTime focusedDay) async {
    // if (selectedDay.isAtSameMomentAs(DateTime.now())) {
    // print('hello');
    bool? result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Clock In'),
          content: Text('Do you want to mark this day as checked in ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
            TextButton(onPressed: ()=> Navigator.of(context).pop(CheckInData[focusedDay]), child: Text('Cancel'),),
          ],
        );
      },
    );
    setState(() {
      this.focusedDay = selectedDay;
    });
    // print(result);
    if (result != null) {
      setState(() {
        CheckInData[selectedDay] = result;
        this.focusedDay = selectedDay;
        this.selectedDay = selectedDay;
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.docID)
          .collection('goal')
          .doc(widget.goalID)
          .collection('plans')
          .doc(widget.planID)
          .collection('date')
          .doc(selectedDay.toIso8601String())
          .set({'checked': result}, SetOptions(merge: true));
    }
    // }
  }

  Future<void> _saveMemo(DateTime date) async {
    for (var memo in memoData[date]!) {
      var memos = memo.toString();
      if (!memo.isEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.docID)
            .collection('goal')
            .doc(widget.goalID)
            .collection('plans')
            .doc(widget.planID)
            .collection('date')
            .doc(date.toIso8601String())
            .update({'memo': memoData[date]});
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.docID)
            .collection('goal')
            .doc(widget.goalID)
            .collection('plans')
            .doc(widget.planID)
            .collection('date')
            .doc(date.toIso8601String())
            .set({'memo': memoData[date]}, SetOptions(merge: true));
      }
    }
  }

  void _addMemo() {
    setState(() {
      memoData[focusedDay!] = memoData[focusedDay] ?? [];
      memoData[focusedDay]!.add('');
    });
  }

  Widget _buildMemoList() {
    if (selectedDay != null) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Memo(s) for ${focusedDay!.toIso8601String().substring(0, 10)}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Icon(
                  CheckInData[focusedDay] == true
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  color: CheckInData[focusedDay] == true
                      ? Colors.green
                      : Colors.red,
                ),
              ],
            ),
          ),
          ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: memoData[focusedDay]?.length ?? 0,
              itemBuilder: (context, index) {
                var memoController =
                    TextEditingController(text: memoData[focusedDay]![index]);
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: memoController,
                          onChanged: (value) {
                            memoData[focusedDay]![index] = value;
                          },
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'memo',
                            hintStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            border: OutlineInputBorder(),
                            fillColor: Color.fromARGB(255, 106, 105, 105),
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.redAccent),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              memoData[focusedDay]!.removeAt(index);
                            });
                          },
                          icon: Icon(Icons.delete)),
                    ],
                  ),
                );
              }),
        ],
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 50,horizontal: 10),
        child: Center(
          child: Text('You can choose day and add memos',
          style: TextStyle(fontSize: 20),),
          
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color.fromARGB(255, 198, 197, 197),
      appBar: AppBar(
        title: Text('Food Plan Clock In'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2030, 1, 1),
                focusedDay: focusedDay!,
                onDaySelected: _ClockIn,
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    if (CheckInData.containsKey(day)) {
                      return Center(
                        child: Icon(
                          CheckInData[day] == true
                              ? Icons.check_circle_outline
                              : Icons.cancel_outlined,
                          color: CheckInData[day] == true
                              ? Colors.green
                              : Colors.red,
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 10),
              _buildMemoList(),
              if (selectedDay != null) // 判断是否选中了日期
                ElevatedButton(
                  onPressed: _addMemo,
                  child: Text('Add'),
                ),
              if (selectedDay != null) // 判断是否选中了日期
                ElevatedButton(
                  onPressed: () => _saveMemo(focusedDay!),
                  child: Text('Save Memo'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
