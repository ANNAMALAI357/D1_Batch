import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:relative_scale/relative_scale.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dashboardUI.dart';

class RouteSelection extends StatefulWidget {
  @override
  _RouteSelectionState createState() => _RouteSelectionState();
}

class _RouteSelectionState extends State<RouteSelection> {
  bool isloading=false;
  Color primary = Color(0xFF304FFE);
  Color secondary = Color(0xFF788Af4);
  Color background = Color(0xfffefefe);

  List<String> temp = ['Select any route'], busStateList = ['Select Your Bus'];
  String dropDownValue = 'Select any route';
  String busDropDown = 'Select Your Bus';
  Map<dynamic, dynamic> dbValues, busValues;

  String token;

  @override
  Widget build(BuildContext context) {
    Map<dynamic, dynamic> values;
    Iterable<dynamic> routes, buses;
    List<String> routeList = ['Select any route'];
    var db = FirebaseDatabase.instance.reference();
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

    SharedPreferences prefs;
    return RelativeBuilder(
        builder: (context, screenHeight, screenWidth, sy, sx) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Pick a Route"),
          backgroundColor: primary,
          centerTitle: true,
        ),
        body: Center(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  margin: EdgeInsets.only(bottom: 30, right: 20),
                  child: Image.asset("assets/pecLogo.png"),
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
                      isExpanded: true,
                      value: dropDownValue,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: primary,
                      ),
                      iconSize: 25,
                      elevation: 16,
                      style: TextStyle(color: primary),
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
                      isExpanded: true,
                      value: busDropDown,
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
                isloading==false?RaisedButton(
                  color: primary,
                  child: Text(
                    'OK',
                    style: TextStyle(color: background),
                  ),
                  onPressed: () async {
                    setState(() {
                      isloading=true;
                    });
                    try{
                      if (dropDownValue != 'Select any route' &&
                          busDropDown != 'Select Your Bus') {
                        prefs = await SharedPreferences.getInstance();

                        String rollNumber = await prefs.getString("userId");

                        if (await prefs.getString("route") != null) {
                          String routeName = await prefs.getString("route");
                          String busNumber = await prefs.getString("bus");
                          var db = FirebaseDatabase.instance.reference();
                          await OneSignal.shared.setSubscription(false);
                          await db.once().then((DataSnapshot snap) {
                            db
                                .child("Bus Routes")
                                .child(routeName)
                                .child(busNumber)
                                .child("Users Registered")
                                .child(rollNumber)
                                .remove();
                            db
                                .child("Bus Routes")
                                .child(routeName)
                                .child(busNumber)
                                .child("Users Subscribed")
                                .child(rollNumber)
                                .remove();
                          });
                        }

                        await prefs.setBool("routeSelected", true);
                        await prefs.setString("route", dropDownValue);
                        await prefs.setString("bus", busDropDown);

                        FirebaseMessaging _firebaseMessaging =
                        FirebaseMessaging();
                        _firebaseMessaging.getToken().then((value) {
                          setState(() {
                            token = value;
                          });
                        });

                        var db = FirebaseDatabase.instance.reference();
                        await db.once().then((DataSnapshot snap) {
                          db
                              .child("Bus Routes")
                              .child(dropDownValue)
                              .child(busDropDown)
                              .child("Users Registered")
                              .child(rollNumber)
                              .update({
                            "Fcm_Token": token,
                          });
                        });

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DashBoardUI(
                                  routeSelected: true,
                                  roll_number: rollNumber,
                                )));
                      } else {
                        Fluttertoast.showToast(
                            msg: "Select Route",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      }
                      setState(() {
                        isloading=false;
                      });
                    }
                    catch(e)
                    {
                      setState(() {
                        isloading=false;
                      });
                      Fluttertoast.showToast(msg: "Something went wrong");
                    }
                  },
                ):CircularProgressIndicator(backgroundColor: Colors.blue,),
              ]),
        ),
      );
    });
  }
}
