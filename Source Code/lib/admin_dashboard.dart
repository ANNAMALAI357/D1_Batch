import 'package:bus_app/adminProfile.dart';
import 'package:bus_app/busFileUpload.dart';
import 'package:bus_app/manualBusUpload.dart';
import 'package:bus_app/manualStudentUpload.dart';
import 'package:bus_app/routeChange.dart';
import 'package:bus_app/student_issues.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:relative_scale/relative_scale.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'adminBusSearch.dart';
import 'adminStudentUpdate.dart';
import 'excel.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Color primary = Color(0xFF304FFE);
  Color secondary = Color(0xFF788Af4);
  Color background = Color(0xfffefefe);

  String userName = "";
  bool isload=false;

  Future<String> loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = await prefs.getString("userName");
    setState(() {
      userName = "Hi " + user;
    });
    return "Hai";
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        showDialog(
            context: this.context,
            child: AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Do you want to exit the app?"),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FlatButton(
                        child: Text("Yes"),
                        onPressed: () => SystemNavigator.pop(),
                      ),
                      FlatButton(
                        child: Text("No"),
                        onPressed: () => Navigator.pop(context, true),
                      ),
                    ],
                  )
                ],
              ),
            ));
      },
      child: RelativeBuilder(
          builder: (context, screenHeight, screenWidth, sy, sx) {
        return Scaffold(
          resizeToAvoidBottomPadding: false,
          body: Container(
            height: screenHeight,
            width: screenWidth,
            color: background,
            padding: EdgeInsets.symmetric(
              vertical: sy(10),
              horizontal: sy(18),
            ),
            child: Column(
              children: [
                ListView(
                  shrinkWrap: true,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: sy(10), horizontal: 0),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            child: loadUserName() != null
                                ? Text(
                                    userName,
                                    style: TextStyle(
                                        color: primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            sy(14) > sx(14) ? sy(14) : sx(14)),
                                    textAlign: TextAlign.center,
                                  )
                                : Container()),
                        isload==false?InkWell(
                          onTap: () async {
                            setState(() {
                              isload=true;
                            });
                            String mobile_num;
                            Map<dynamic, dynamic> advalues;
                            var db = FirebaseDatabase.instance.reference();
                            await db.once().then((DataSnapshot snap) {
                              advalues = snap.value;
                              advalues = advalues['LoginDetails'];
                              advalues = advalues['Admin Access'];
                              mobile_num = advalues['ADMINPROJECT'];
                              setState(() {
                                isload=false;
                              });
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Admin_Profile(
                                            mobile: mobile_num,
                                          )));
                            });
                          },
                          child: Container(
                            child: Icon(
                              Icons.supervised_user_circle_outlined,
                              color: primary,
                              size: 40,
                            ),
                          ),
                        ):CircularProgressIndicator(backgroundColor: Colors.white,),
                      ],
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: sy(20), horizontal: 0),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: sy(10), vertical: 0),
                          width: sx(220),
                          height: sy(100),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AdminBusSelection()));
                            },
                            child: Card(
                              child: Center(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_searching_rounded,
                                    size: sx(50),
                                    color: primary,
                                  ),
                                  Text("Locate Bus")
                                ],
                              )),
                              color: background,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              shadowColor: secondary,
                              elevation: 3,
                            ),
                          ),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: sy(10), vertical: 0),
                          width: sx(220),
                          height: sy(100),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RouteChange()));
                            },
                            child: Card(
                              child: Center(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.alt_route_outlined,
                                    size: sx(50),
                                    color: primary,
                                  ),
                                  Text("Route Change")
                                ],
                              )),
                              color: background,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              shadowColor: secondary,
                              elevation: 3,
                            ),
                          ),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                        ),
                      ],
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: sy(4), horizontal: 0),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: sy(10), vertical: 0),
                          width: sx(220),
                          height: sy(100),
                          child: InkWell(
                            onTap: () {
                              return showDialog<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Select the form of Upload'),
                                    content: SingleChildScrollView(
                                      child: ListBody(
                                        children: <Widget>[
                                          RaisedButton(
                                            child: Text(
                                              "Upload File",
                                              style:
                                                  TextStyle(color: background),
                                            ),
                                            color: primary,
                                            onPressed: () {
                                              Navigator.pop(context,true);
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          MyFiles()));

                                            },
                                          ),
                                          RaisedButton(
                                            child: Text(
                                              "Manual Upload",
                                              style:
                                                  TextStyle(color: background),
                                            ),
                                            color: primary,
                                            onPressed: () {
                                              Navigator.pop(context,true);
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ManualStudentUpload()));

                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text(
                                          'Close',
                                          style: TextStyle(color: secondary),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Card(
                              child: Center(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cloud_upload_outlined,
                                    size: sx(50),
                                    color: primary,
                                  ),
                                  Text("Upload Student"),
                                  Text("Data"),
                                ],
                              )),
                              color: background,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              shadowColor: secondary,
                              elevation: 3,
                            ),
                          ),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: sy(10), vertical: 0),
                          width: sx(220),
                          height: sy(100),
                          child: InkWell(
                            onTap: () {
                              return showDialog<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Select the form of Upload'),
                                    content: SingleChildScrollView(
                                      child: ListBody(
                                        children: <Widget>[
                                          RaisedButton(
                                            child: Text(
                                              "Upload File",
                                              style:
                                                  TextStyle(color: background),
                                            ),
                                            color: primary,
                                            onPressed: () {
                                              Navigator.pop(context,true);
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          BusFiles()));
                                            },
                                          ),
                                          RaisedButton(
                                            child: Text(
                                              "Manual Upload",
                                              style:
                                                  TextStyle(color: background),
                                            ),
                                            color: primary,
                                            onPressed: () {
                                              Navigator.pop(context,true);
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ManualBusUpload()));
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text(
                                          'Close',
                                          style: TextStyle(color: secondary),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Card(
                              child: Center(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cloud_upload_outlined,
                                    size: sx(50),
                                    color: primary,
                                  ),
                                  Text("Upload Bus"),
                                  Text("Details"),
                                ],
                              )),
                              color: background,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              shadowColor: secondary,
                              elevation: 3,
                            ),
                          ),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                        ),
                      ],
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: sy(4), horizontal: 0),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: sy(10), vertical: 0),
                          width: sx(220),
                          height: sy(100),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => StudentUpdate()));
                            },
                            child: Card(
                              child: Center(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.update,
                                    size: sx(50),
                                    color: primary,
                                  ),
                                  Text("Update Student"),
                                  Text("Data")
                                ],
                              )),
                              color: background,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              shadowColor: secondary,
                              elevation: 3,
                            ),
                          ),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: sy(10), vertical: 0),
                          width: sx(220),
                          height: sy(100),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Student_Issues()));
                            },
                            child: Card(
                              child: Center(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person_pin,
                                    size: sx(50),
                                    color: primary,
                                  ),
                                  Text("Student Request")
                                ],
                              )),
                              color: background,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              shadowColor: secondary,
                              elevation: 3,
                            ),
                          ),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
