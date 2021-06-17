import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:relative_scale/relative_scale.dart';

class ManualStudentUpload extends StatefulWidget {
  @override
  _ManualStudentUploadState createState() => _ManualStudentUploadState();
}

class _ManualStudentUploadState extends State<ManualStudentUpload> {
  Color primary = Color(0xFF304FFE);
  Color secondary = Color(0xFF788Af4);
  Color background = Color(0xfffefefe);
  bool isload = false;
  String name, rollNumber, mobileNumber = "+91";

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  var db = FirebaseDatabase.instance.reference();
  Map<dynamic, dynamic> values;

  @override
  Widget build(BuildContext context) {
    return RelativeBuilder(
        builder: (context, screenHeight, screenWidth, sy, sx) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Upload Student Information"),
          centerTitle: true,
          backgroundColor: primary,
        ),
        // resizeToAvoidBottomInset: false,
        body: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formkey,
              child: Container(
                height: sy(350),
                width: sx(400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 5,
                      child: Image.asset('assets/pecLogo.png'),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Flexible(
                      flex: 3,
                      child: TextFormField(
                        keyboardType: TextInputType.name,
                        onChanged: (input) => name = input,
                        validator: (input) {
                          if (input.length == 0) {
                            return "Name cannot be empty";
                          }
                        },
                        cursorColor: secondary,
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
                    SizedBox(
                      height: 15,
                    ),
                    Flexible(
                      flex: 3,
                      child: TextFormField(
                        textCapitalization: TextCapitalization.characters,
                        onChanged: (input) => rollNumber = input,
                        validator: (input) {
                          if (input.length == 0) {
                            return "Enter a valid roll number";
                          }
                        },
                        cursorColor: secondary,
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
                    SizedBox(
                      height: 15,
                    ),
                    Flexible(
                      flex: 3,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        onChanged: (input) => mobileNumber = ("+91" + input),
                        validator: (input) {
                          if (input.length == 0 && input.length < 10) {
                            return "Enter a valid mobile number";
                          } else if (input.length < 10) {
                            return "Enter a valid mobile number";
                          }
                        },
                        cursorColor: secondary,
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
                    SizedBox(
                      height: 10,
                    ),
                    isload==false?RaisedButton(
                      child: Text(
                        "Upload",
                        style: TextStyle(color: background),
                      ),
                      color: primary,
                      onPressed: () async {
                        setState(() {
                          isload = true;
                        });
                        await db.once().then((DataSnapshot snap) {
                          values = snap.value;
                          values = values['LoginDetails'];
                          values = values['Student'];
                        });
                        if (_formkey.currentState.validate()) {
                          Fluttertoast.showToast(msg: "Uploading data");
                          await db
                              .child("LoginDetails/Student")
                              .child(rollNumber.trim())
                              .set({
                            "Name": name.trim(),
                            "Mobile": mobileNumber.trim()
                          });
                          await db
                              .child("LoginDetails/Student")
                              .child(rollNumber.trim())
                              .child("Your Notifications")
                              .set({"Dummy": "notification"});
                          setState(() {
                            isload=false;
                          });
                          Fluttertoast.showToast(
                              msg: "Data uploaded successfully");
                        }
                        else
                          {
                            isload = false;
                          }
                      },
                    ):CircularProgressIndicator(backgroundColor: Colors.white,)
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
