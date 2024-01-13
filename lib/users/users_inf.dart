import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserInfoInputPage extends StatefulWidget {
  final String docID;
  const UserInfoInputPage({super.key, required this.docID});

  @override
  State<UserInfoInputPage> createState() => _UserInfoInputPageState();
}

class _UserInfoInputPageState extends State<UserInfoInputPage> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _bodyfatrateController = TextEditingController();
  final _hiplineController = TextEditingController();
  final _waistlineController = TextEditingController();
  double? _bmi;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _weightController.addListener(_updateBMI);
    _heightController.addListener(_updateBMI);
  }

  Future save() async {
    addUserInf(
        _weightController.text.trim(),
        _heightController.text.trim(),
        _bodyfatrateController.text.trim(),
        _hiplineController.text.trim(),
        _waistlineController.text.trim());
  }

  Future<void> _loadUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.docID)
        .collection('info').doc(widget.docID)
        .get();

    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      setState(() {
        _weightController.text = userData['weight']?.toString() ?? '';
        _heightController.text = userData['height']?.toString() ?? '';
        _bodyfatrateController.text = userData['body_fat']?.toString() ?? '';
        _hiplineController.text = userData['hipline']?.toString() ?? '';
        _waistlineController.text = userData['waistline']?.toString() ?? '';
        _bmi = userData['BMI'];
      });
      // if (userData['weight'] != '' && userData['height'] != '') {
      //   FirebaseFirestore.instance
      //       .collection('users')
      //       .doc(widget.docID)
      //       .collection('info')
      //       .doc()
      //       .set({
      //     'BMI': userData['weight'] / (userData['height'] * userData['height']),
      //   });
      // }
    }
    // print(userData['weight']);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _bodyfatrateController.dispose();
    _hiplineController.dispose();
    _waistlineController.dispose();
    super.dispose();
  }

  Future addUserInf(String? weight, String? height, String? bodyfat,
      String? hipline, String? waistline) async {
    double? weightVal = double.tryParse(weight!);
    double? heightVal = double.tryParse(height!);
    double? bodyFatVal = double.tryParse(bodyfat!);
    double? hiplineVal = double.tryParse(hipline!);
    double? waistlineVal = double.tryParse(waistline!);

    double bmi = 0.0;
    if (weightVal != null && heightVal != null && heightVal != 0) {
      bmi = weightVal / (heightVal * heightVal);
    }

    Map<String, dynamic> userData = {
      'weight': weightVal,
      'height': heightVal,
      'BMI': bmi,
      'body_fat': bodyFatVal,
      'hipline': hiplineVal,
      'waistline': waistlineVal,
    };

    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('users').doc(widget.docID);
    CollectionReference infoCollectionRef = userDocRef.collection('info');
    await infoCollectionRef.doc(widget.docID).set(userData, SetOptions(merge: true));
    // print(widget.docID);
  }

  void _updateBMI() {
    double? weightVal = double.tryParse(_weightController.text);
    double? heightVal = double.tryParse(_heightController.text);

    if (weightVal != null && heightVal != null && heightVal != 0) {
      setState(() {
        _bmi = weightVal / (heightVal * heightVal);
      });
    } else {
      setState(() {
        _bmi = null;
      });
    }
  }

  void _calculateAndSetBMI() {
    double? weightVal = double.tryParse(_weightController.text);
    double? heightVal = double.tryParse(_heightController.text);

    if (weightVal != null && heightVal != null && heightVal != 0) {
      setState(() {
        _bmi = weightVal / (heightVal * heightVal);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: Text('User Information'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Icon(
                  Icons.info,
                  size: 100,
                  color: Colors.grey,
                ),
                SizedBox(height: 30.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    controller: _weightController,
                    decoration: InputDecoration(
                      labelText: 'Weight(kg)',
                      labelStyle: TextStyle(color: Colors.white),
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
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    controller: _heightController,
                    decoration: InputDecoration(
                      labelText: 'Height(m)',
                      labelStyle: TextStyle(color: Colors.white),
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
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: _bmi != null
                      ? Text(
                          'BMI: ${_bmi!.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        )
                      : Text(
                          'BMI: Null',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    controller: _bodyfatrateController,
                    decoration: InputDecoration(
                      labelText: 'Body Fat Rate(%)',
                      labelStyle: TextStyle(color: Colors.white),
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
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    controller: _hiplineController,
                    decoration: InputDecoration(
                      labelText: 'hipline(cm)',
                      labelStyle: TextStyle(color: Colors.white),
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
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    controller: _waistlineController,
                    decoration: InputDecoration(
                      labelText: 'Waistline(cm)',
                      labelStyle: TextStyle(color: Colors.white),
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
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Center(
                    child: GestureDetector(
                      onTap: () => save(),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 25.0, vertical: 15.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            border:
                                Border.all(width: 2.0, color: Colors.white)),
                        child: Text(
                          'Save Information',
                          style: TextStyle(
                              fontFamily: 'Rubik Doodle Shadow',
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
