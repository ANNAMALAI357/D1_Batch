
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:relative_scale/relative_scale.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RouteChange extends StatefulWidget {
  @override
  _RouteChangeState createState() => _RouteChangeState();
}

class _RouteChangeState extends State<RouteChange> {
  Color primary = Color(0xFF304FFE);
  Color secondary = Color(0xFF788Af4);
  Color background = Color(0xfffefefe);

  List<String> temp = ['Select any route'], busStateList = ['Select Your Bus'];
  String dropDownValue = 'Select any route';
  String busDropDown = 'Select Your Bus';
  Map<dynamic, dynamic> dbValues, busValues;

  bool readOnly = true;
  bool revert_button=false,update_button=false;
  String routeChangeValue = "";

  Map<dynamic, dynamic> values;
  Iterable<dynamic> routes, buses;
  String number;
  String token;
  var db;

  void getDatabase() {
    List<String> routeList = ['Select any route'];
    db = FirebaseDatabase.instance.reference();
    db.once().then((DataSnapshot snap) {
      values = snap.value;
      values = values['Bus Routes'];
      routes = values.keys;
      routes.forEach((element) {
        routeList.add(element);
      });
      setState(() {
        temp = routeList;
        dbValues = values;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getDatabase();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RelativeBuilder(
        builder: (context, screenHeight, screenWidth, sy, sx) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("Change Route"),
          backgroundColor: primary,
          centerTitle: true,
        ),
        body: KeyboardAvoider(
          autoScroll: true,
          child: Center(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              Container(
              child: Image.asset(
                'assets/pecLogo.png',
                height: sy(100),
                fit: BoxFit.cover,
              )),
                  Divider(height: sy(10),color: Colors.white,),
                  DropdownButtonHideUnderline(
                    child: Container(
                      padding: EdgeInsets.only(left: 5),
                      margin:
                          EdgeInsets.symmetric(vertical: sy(3), horizontal: 0),
                      width: sx(230),
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                              width: 1.0,
                              style: BorderStyle.solid,
                              color: secondary),
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        ),
                      ),
                      child: DropdownButton(
                        value: dropDownValue,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: primary,
                        ),
                        iconSize: 25,
                        elevation: 16,
                        style: TextStyle(color: primary),
                        isExpanded: true,
                        underline: Container(
                          height: 2,
                          color: primary,
                        ),
                        onChanged: (String newValue) {
                          List<String> busList = ['Select Your Bus'];
                          values = dbValues[newValue];
                          buses = values.keys;
                          buses.forEach((element) {
                            busList.add(element);
                          });
                          setState(() {
                            dropDownValue = newValue;
                            busStateList = busList;
                            busValues = values;
                            busDropDown = 'Select Your Bus';
                          });
                        },
                        items: temp.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  DropdownButtonHideUnderline(
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(vertical: sy(3), horizontal: 0),
                      padding: EdgeInsets.only(left: 5),
                      width: sx(230),
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                              width: 1.0,
                              style: BorderStyle.solid,
                              color: secondary),
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        ),
                      ),
                      child: DropdownButton(
                        value: busDropDown,
                        isExpanded: true,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: primary,
                        ),
                        iconSize: 25,
                        elevation: 16,
                        style: TextStyle(color: primary),
                        underline: Container(
                          height: 2,
                          color: primary,
                        ),
                        onChanged: (String newValue) {
                          values = busValues[newValue];
                          setState(() {
                            busDropDown = newValue;
                            routeChangeValue = values["Route Change"];
                          });
                        },
                        items: busStateList
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: sy(7), horizontal: 0),
                    width: sx(230),
                    height: sy(35),
                    child: TextFormField(
                      readOnly: readOnly,
                      initialValue: routeChangeValue,
                      cursorColor: secondary,
                      focusNode: FocusNode(canRequestFocus: false),
                      onChanged: (input) => number = input,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Bus Number",
                        focusColor: secondary,
                        labelStyle: TextStyle(
                          color: primary,
                          fontSize: sx(18),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(
                            color: secondary,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide:
                              BorderSide(color: Color.fromRGBO(48, 79, 254, .2)),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide:
                              BorderSide(color: Color.fromRGBO(48, 79, 254, .2)),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide:
                              BorderSide(color: Color.fromRGBO(48, 79, 254, .2)),
                        ),
                      ),
                    ),
                  ),
                  RaisedButton(
                    color: primary,
                    child: Text(
                      'Edit',
                      style: TextStyle(color: background),
                    ),
                    onPressed: () async {
                      setState(() {
                        readOnly = false;
                      });
                      Fluttertoast.showToast(msg: "Now you can edit the route");
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      readOnly == true
                          ? Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: sx(5)),
                              child: revert_button==false?RaisedButton(
                                color: primary,
                                child: Text(
                                  'Revert',
                                  style: TextStyle(color: background),
                                ),
                                onPressed: () async {
                                  setState(() {
                                    revert_button=true;
                                  });
                                  if (dropDownValue != "Select any route" &&
                                      busDropDown != "Select Your Bus") {
                                    db
                                        .child("Bus Routes")
                                        .child(dropDownValue)
                                        .child(busDropDown)
                                        .update({"Route Change": "No"});
                                    setState(() {
                                      revert_button=false;
                                    });
                                    Fluttertoast.showToast(msg: "Route Reverted");
                                  }
                                  else{
                                    setState(() {
                                      revert_button=false;
                                    });
                                    Fluttertoast.showToast(msg: "Kindly select the route");
                                  }

                                },
                              ):CircularProgressIndicator(backgroundColor: Colors.white,),
                            )
                          : Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: sx(5)),
                              child: RaisedButton(
                                color: primary,
                                child: Text(
                                  'Revert',
                                  style: TextStyle(color: background),
                                ),
                                onPressed: null,
                              ),
                            ),
                      readOnly == false
                          ? Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: sx(5)),
                              child: update_button==false?RaisedButton(
                                color: primary,
                                child: Text(
                                  'Update',
                                  style: TextStyle(color: background),
                                ),
                                onPressed: () async {
                                  setState(() {
                                    update_button=true;
                                  });
                                  if (dropDownValue != "Select any route" &&
                                      busDropDown != "Select Your Bus") {
                                    db
                                        .child("Bus Routes")
                                        .child(dropDownValue)
                                        .child(busDropDown)
                                        .update({"Route Change": number});
                                    setState(() {
                                      update_button=false;
                                    });
                                    Fluttertoast.showToast(msg: "Route Updated");
                                  }
                                  else
                                    {
                                      setState(() {
                                        update_button=false;
                                      });
                                      Fluttertoast.showToast(msg: "Kindly select the route");
                                    }

                                },
                              ):CircularProgressIndicator(backgroundColor: Colors.white,),
                            )
                          : Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: sx(5)),
                              child: RaisedButton(
                                color: primary,
                                child: Text(
                                  'Update',
                                  style: TextStyle(color: background),
                                ),
                                onPressed: null,
                              ),
                            )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
