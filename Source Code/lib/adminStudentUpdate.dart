

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:relative_scale/relative_scale.dart';

class StudentUpdate extends StatefulWidget {
  @override
  _StudentUpdateState createState() => _StudentUpdateState();
}

class _StudentUpdateState extends State<StudentUpdate> {
  Color primary = Color(0xFF304FFE);
  Color secondary = Color(0xFF788Af4);
  Color background = Color(0xfffefefe);
  bool isload=true;
  bool user_load=false;
  Map<dynamic, dynamic> values;
  List<String> studentList = [];
  Iterable<dynamic> students;

  void getDataBase() async {
    List<String> temp = [];
    var db = FirebaseDatabase.instance.reference();
    await db.once().then((DataSnapshot snap) {
      values = snap.value;
      values = values['LoginDetails'];
      values = values['Student'];
      students = values.keys;
      students.forEach((element) {
        temp.add(element);
      });
    });
    setState(() {
      studentList = temp;
      isload=false;
    });
  }

  @override
  void initState() {
    super.initState();
    getDataBase();
  }

  @override
  Widget build(BuildContext context) {
    return RelativeBuilder(
        builder: (context, screenHeight, screenWidth, sy, sx) {
      return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Update Student Information',
            style: TextStyle(fontSize: sy(15) > sx(15) ? sy(15) : sx(15)),
          ),
          backgroundColor: primary,
        ),
        body: Container(
          height: screenHeight,
          width: screenWidth,
          color: background,
          padding: EdgeInsets.symmetric(
            vertical: sy(10),
            horizontal: sy(14),
          ),
          child: Column(
            children: [
              Container(
                child: Text(
                  'Select the Roll Number to Update',
                  style: TextStyle(fontSize: sy(13) > sx(13) ? sy(13) : sx(13)),
                ),
              ),
              Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: sy(10) > sx(10) ? sy(10) : sx(10))),
              isload==false?ListView.builder(
                shrinkWrap: true,
                primary: false,
                itemCount: studentList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Container(
                      padding: EdgeInsets.all(
                        sx(20),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: Color.fromRGBO(120, 138, 244, .3),
                        ),
                      ),
                      child: Text(studentList[index]),
                    ),
                    onTap: () async {
                      setState(() {
                        user_load=true;
                      });
                      await getDataBase();
                      values = values[studentList[index]];
                      var name = values["Name"];
                      var mobile = values["Mobile"];
                      setState(() {
                        user_load=false;
                      });
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UpdateInfo(
                                    rollNumber: studentList[index],
                                    userName: name,
                                    mobileNumber: mobile,
                                  )));
                    },
                  );
                },
              ):CircularProgressIndicator(backgroundColor: Colors.white,),
              user_load==true?Container(
                  margin: EdgeInsets.only(top:20),
                  child: CircularProgressIndicator(backgroundColor: Colors.white,)):Container()
            ],
          ),
        ),
      );
    });
  }
}

class UpdateInfo extends StatefulWidget {
  const UpdateInfo(
      {Key key,
      @required this.rollNumber,
      @required this.userName,
      @required this.mobileNumber})
      : super(key: key);
  final String rollNumber;
  final String userName;
  final String mobileNumber;

  @override
  _UpdateInfoState createState() => _UpdateInfoState(
      rollNumber: rollNumber, userName: userName, mobileNumber: mobileNumber);
}

class _UpdateInfoState extends State<UpdateInfo> {
  _UpdateInfoState(
      {Key key,
      @required this.rollNumber,
      @required this.userName,
      @required this.mobileNumber});
  final String rollNumber;
  final String userName;
  final String mobileNumber;

  bool readOnly = true;
  bool isload=false;
  String newNumber;

  Color primary = Color(0xFF304FFE);
  Color secondary = Color(0xFF788Af4);
  Color background = Color(0xfffefefe);

  Map<dynamic, dynamic> values;

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  String updatedMobileNumber = "";
  var db = FirebaseDatabase.instance.reference();

  @override
  Widget build(BuildContext context) {
    return RelativeBuilder(
        builder: (context, screenHeight, screenWidth, sy, sx) {
      return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text('Student Information'),
          centerTitle: true,
          backgroundColor: primary,
        ),
        body: KeyboardAvoider(
          autoScroll: true,
          child: Center(
            child: Container(
              height: sy(450),
              width: sx(400),

              padding: EdgeInsets.symmetric(
                vertical: sy(10),
                horizontal: sy(14),
              ),
              child: Column(
                children: [
                  Container(
                      child: Image.asset(
                        'assets/pecLogo.png',
                        height: sy(100),
                        fit: BoxFit.cover,
                      )),
                  Divider(height: sy(10),color: Colors.white,),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0)),
                  Flexible(
                    flex: 2,
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 0,
                      ),
                      child: TextFormField(
                        initialValue: userName,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Name",
                          focusColor: secondary,
                          labelStyle: TextStyle(
                            color: primary,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: secondary,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: secondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 0,
                      ),
                      child: TextFormField(
                        initialValue: rollNumber,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Roll Number",
                          focusColor: secondary,
                          labelStyle: TextStyle(
                            color: primary,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: secondary,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: secondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 3,
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 0,
                          ),
                          child: Form(
                            key: _formkey,
                            child: TextFormField(
                              focusNode: FocusNode(canRequestFocus: false),
                              initialValue: mobileNumber,
                              onSaved: (input) => newNumber = input,
                              validator: (input) {
                                if (input.length == 0 && input.length < 13) {
                                  return "Enter a valid mobile number";
                                } else if (input.length > 13) {
                                  return "Enter a valid mobile number";
                                }
                                if (input == mobileNumber) {
                                  return "Old number and new number \n are same";
                                }
                              },
                              cursorColor: secondary,
                              readOnly: readOnly,
                              decoration: InputDecoration(
                                labelText: "Mobile Number",
                                focusColor: secondary,
                                labelStyle: TextStyle(
                                  color: primary,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: secondary,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Color.fromRGBO(48, 79, 254, .2)),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Color.fromRGBO(48, 79, 254, .2)),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Color.fromRGBO(48, 79, 254, .2)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                          child: Container(
                        margin: EdgeInsets.only(
                          left: sx(15),
                        ),
                        decoration: BoxDecoration(
                          color: primary,
                          border: Border.all(
                            color: secondary,
                          ),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: IconButton(
                            icon: Icon(
                              Icons.edit_outlined,
                              color: background,
                            ),
                            onPressed: () {
                              setState(() {
                                readOnly = false;
                              });
                            }),
                      )),
                    ],
                  ),
                  isload==false?RaisedButton(
                    color: primary,
                    onPressed: () async {
                      setState(() {
                        isload=true;
                      });
                      final formstate = _formkey.currentState;
                      if (formstate.validate()) {
                        formstate.save();
                        setState(() {
                          readOnly = true;
                        });
                        Fluttertoast.showToast(msg: "Please wait...");
                        await FirebaseDatabase.instance
                            .reference()
                            .child("LoginDetails")
                            .child("Student")
                            .child(rollNumber)
                            .update({"Mobile": newNumber});
                        setState(() {
                          isload=false;
                        });
                        Fluttertoast.showToast(
                            msg: "Mobile number updated successfully");
                      }
                      else
                        {
                          setState(() {
                            isload=false;
                          });
                        }
                    },
                    child: Text(
                      "Save",
                      style: TextStyle(color: background),
                    ),
                  ):CircularProgressIndicator(backgroundColor: Colors.white,)
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
