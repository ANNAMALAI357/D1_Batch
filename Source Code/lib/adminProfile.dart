import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:relative_scale/relative_scale.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'loginPage.dart';

class Admin_Profile extends StatefulWidget {
  const Admin_Profile({Key key, @required this.mobile}) : super(key: key);
  final String mobile;
  @override
  _Admin_ProfileState createState() => _Admin_ProfileState(mobile: mobile);
}

class _Admin_ProfileState extends State<Admin_Profile> {
  _Admin_ProfileState({Key key, @required this.mobile});
  final String mobile;

  String newnumber;

  bool readOnly = true, editPressed = false;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool isload=false,logout_load=false;
  Color primary = Color(0xFF304FFE);
  Color secondary = Color(0xFF788Af4);
  Color background = Color(0xfffefefe);

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return RelativeBuilder(
        builder: (context, screenHeight, screenWidth, sy, sx) {
      return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          centerTitle: true,
          title: Text("Admin Details"),
          backgroundColor: primary,
        ),
        body: KeyboardAvoider(
          autoScroll: true,
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.supervised_user_circle,
                  color: primary,
                  size: sx(90),
                ),
                Padding(
                  padding: EdgeInsets.only(top: sy(30)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                        flex: 2,
                        child: Container(
                          child: Form(
                            key: _formkey,
                            child: TextFormField(
                              focusNode: FocusNode(canRequestFocus: false),
                              initialValue: mobile,
                              onSaved: (input) => newnumber = input,
                              validator: (input) {
                                if (input.length == 0 && input.length < 13) {
                                  return "Enter a valid mobile number";
                                } else if (input.length > 13) {
                                  return "Enter a valid mobile number";
                                }
                                if (input == mobile) {
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
                        )),
                    Flexible(
                        child: Container(
                      margin: EdgeInsets.only(
                        left: sx(15),
                      ),
                      decoration: BoxDecoration(
                        color: primary,
                        border: Border.all(color: secondary),
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
                              editPressed = true;
                            });
                          }),
                    ))
                  ],
                ),
                editPressed == true
                    ? Container(
                        margin: EdgeInsets.only(top: 20),
                        child: isload==false?RaisedButton(
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
                                  .child("Admin Access")
                                  .update({"ADMINPROJECT": newnumber});
                              setState(() {
                                isload=false;
                                editPressed=false;
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
                        ):CircularProgressIndicator(backgroundColor: Colors.white,))
                    : Container(),
                Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Center(
                      child: logout_load==false?RaisedButton(
                        color: primary,
                        child: Text(
                          "Logout",
                          style: TextStyle(color: background),
                        ),
                        onPressed: () async {
                          setState(() {
                            logout_load=true;
                          });
                          await _auth.signOut();
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.clear();
                          setState(() {
                            logout_load=false;
                          });
                          Fluttertoast.showToast(msg: "Logging you Out");
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()));
                        },
                      ):CircularProgressIndicator(backgroundColor: Colors.white,),
                    ))
              ],
            ),
          ),
        ),
      );
    });
  }
}
