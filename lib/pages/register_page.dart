import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showRegisterPage;

  const RegisterPage({super.key, required this.showRegisterPage});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usrNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPwdController = TextEditingController();
  String sex = 'MALE';
  final _birthdateController = TextEditingController();

  @override
  void dispose() {
    _usrNameController.dispose();
    _emailController.dispose();
    _birthdateController.dispose();
    _passwordController.dispose();
    _confirmPwdController.dispose();
    super.dispose();
  }

  void showAlertDialog(String message){
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: Text('Warning'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future signUp() async {
    if (_usrNameController.text.isEmpty) {
      showAlertDialog('Username is required');
      return;
    }

    if (_birthdateController.text.isEmpty) {
      showAlertDialog('Birthday is required');
      return;
    }

    if (_emailController.text.isEmpty) {
      showAlertDialog('Email is required');
      return;
    }

    if (_passwordController.text.isEmpty) {
      showAlertDialog('Password is required');
      return;
    }

    if (_confirmPwdController.text.isEmpty) {
      showAlertDialog('Confirm Password is required');
      return;
    }
    
  
    if (passwordConfirmed()) {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());

      addUserDetails(
          _usrNameController.text.trim(),
          _emailController.text.trim(),
          sex,
          DateFormat('dd MMM, yyyy').parse(_birthdateController.text));
    }
  }

  bool passwordConfirmed() {
    if (_passwordController.text == _confirmPwdController.text)
      return true;
    else
      return false;
  }

  Future addUserDetails(
      String usrName, String email, String sex, DateTime birthdate) async {
    await FirebaseFirestore.instance.collection('users').doc(email).set({
      'usrname': usrName,
      'email': email,
      'sex': sex,
      'age': birthdate,
      'score': 0,
      'friends': {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(
                Icons.sports,
                size: 100,
                color: Color.fromARGB(255, 178, 173, 173),
              ),
              Text(
                'Join Us!',
                style: TextStyle(
                    fontFamily: 'Rubik Doodle Shadow',
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  controller: _usrNameController,
                  decoration: InputDecoration(
                    hintText: 'USER NAME',
                    hintStyle: TextStyle(
                      color: Colors.white,
                    ),
                    fillColor: Color.fromARGB(255, 47, 46, 46),
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color.fromARGB(255, 31, 30, 30))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white)),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 165,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          icon: Icon(Icons.person),
                          iconColor: Color.fromARGB(255, 178, 173, 173),
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        dropdownColor: Color.fromARGB(255, 158, 154, 154),
                        value: sex,
                        items: <String>['MALE', 'FEMALE', 'NOT SHARE']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            sex = value!;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: TextFormField(
                          controller: _birthdateController,
                          decoration: InputDecoration(
                            icon: Icon(Icons.calendar_today),
                            iconColor: Color.fromARGB(255, 178, 173, 173),
                            hintText: "Birthdate",
                            hintStyle: TextStyle(color: Colors.white),
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          readOnly: true,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1960),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null) {
                              String formattedDate =
                                  DateFormat('dd MMM, yyyy').format(pickedDate);
                              setState(() {
                                _birthdateController.text = formattedDate;
                              });
                            }
                          }),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'EMAIL',
                    hintStyle: TextStyle(
                      color: Colors.white,
                    ),
                    fillColor: Color.fromARGB(255, 47, 46, 46),
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color.fromARGB(255, 31, 30, 30))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white)),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'PASSWORD',
                    hintStyle: TextStyle(
                      color: Colors.white,
                    ),
                    fillColor: Color.fromARGB(255, 47, 46, 46),
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color.fromARGB(255, 31, 30, 30))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white)),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  controller: _confirmPwdController,
                  decoration: InputDecoration(
                    hintText: 'CONFIRM PASSWORD',
                    hintStyle: TextStyle(
                      color: Colors.white,
                    ),
                    fillColor: Color.fromARGB(255, 47, 46, 46),
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color.fromARGB(255, 31, 30, 30))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white)),
                  ),
                ),
              ),
              SizedBox(
                height: 25.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Center(
                  child: GestureDetector(
                    onTap: signUp,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(width: 2.0, color: Colors.white)),
                      child: Text(
                        'SIGN UP',
                        style: TextStyle(
                            fontFamily: 'Rubik Doodle Shadow',
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'I am a member',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: widget.showRegisterPage,
                    child: Text(
                      'Login now',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              )
            ]),
          ),
        ),
      ),
    );
  }
}
