import 'package:flutter/material.dart';

class GroupGoalPage extends StatefulWidget {
  const GroupGoalPage({super.key});

  @override
  State<GroupGoalPage> createState() => _GroupGoalPageState();
}

class _GroupGoalPageState extends State<GroupGoalPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 178, 173, 173),
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
          ],
        ),
      )),
    );
  }
}
