import 'package:bus_app/userprofile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:relative_scale/relative_scale.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'busUpdatesStudent.dart';
import 'mapScreen.dart';
import 'routeSelection.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_database/firebase_database.dart';

class DashBoardUI extends StatefulWidget {
  const DashBoardUI(
      {Key key, @required this.routeSelected, @required this.roll_number})
      : super(key: key);
  final String roll_number;
  final bool routeSelected;

  @override
  _DashBoardState createState() =>
      _DashBoardState(routeSelected: routeSelected, roll_number: roll_number);
}

class _DashBoardState extends State<DashBoardUI> {
  Color primary = Color(0xFF304FFE);
  Color secondary = Color(0xFF788Af4);
  Color background = Color(0xfffefefe);
  bool opts = false;
  bool isload=false;

  String token;
  double latitude, longitude;

  _DashBoardState(
      {Key key, @required this.routeSelected, @required this.roll_number});
  final String roll_number;
  final bool routeSelected;
  String userName = "";

  Future<String> loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = await prefs.getString("userName");
    setState(() {
      userName = "Hi " + user;
    });
    return "Hai";
  }

  int radioValue = -1;

  void _handleRadioValueChanged(int value) {
    setState(() {
      radioValue = value;
    });
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
          body: Container(
            height: screenHeight,
            width: screenWidth,
            color: background,
            padding: EdgeInsets.symmetric(
              vertical: sy(10),
              horizontal: sy(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListView(
                  shrinkWrap: true,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            child: loadUserName() != null
                                ? Text(
                                    userName,
                                    style: TextStyle(
                                        color: primary,
                                        fontStyle: FontStyle.italic,
                                        fontSize:
                                            sy(14) > sx(14) ? sy(14) : sx(14)),
                                    textAlign: TextAlign.center,
                                  )
                                : Container()),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UserProfile()));
                          },
                          child: Container(
                            child: Icon(
                              Icons.supervised_user_circle_outlined,
                              color: primary,
                              size: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: sy(20), horizontal: 0),
                    ),
                    routeSelected == true
                        ? InkWell(
                            child: Container(
                              child: MapScreen(),
                              height: sy(200),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 2.0,
                                  color: Colors.black,
                                  style: BorderStyle.solid,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                            onLongPress: () {
                              return Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MapScreen()),
                              );
                            },
                          )
                        : Container(
                            height: sy(200),
                            child: Center(
                              child: Container(
                                width: sx(250),
                                margin: EdgeInsets.only(top: sy(100)),
                                child: RaisedButton(
                                  child: Text(
                                    'Select Route',
                                    style: TextStyle(
                                        color: background, fontSize: 16),
                                  ),
                                  color: primary,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(30.0)),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                RouteSelection()));
                                  },
                                ),
                              ),
                            ),
                            decoration: BoxDecoration(
                                border: Border.all(
                                  width: 2.0,
                                  color: Colors.black,
                                  style: BorderStyle.solid,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                image: DecorationImage(
                                  image:
                                      ExactAssetImage('assets/dashboard.jpg'),
                                  fit: BoxFit.cover,
                                )),
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
                          height: sy(125),
                          child: InkWell(
                            onTap: () {
                              showDialog<void>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    int selectedRadio = 1;
                                    return AlertDialog(
                                      content: StatefulBuilder(
                                        builder: (BuildContext context,
                                            StateSetter setState) {
                                          return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                    "Do you want reminders if the bus is within 5 kms of your current location?"),
                                                ListTile(
                                                    title: Text("Enable"),
                                                    leading: Radio<int>(
                                                      value: 1,
                                                      groupValue: selectedRadio,
                                                      onChanged: (int value) {
                                                        setState(() =>
                                                            selectedRadio =
                                                                value);
                                                      },
                                                    )),
                                                ListTile(
                                                    title: Text("Disable"),
                                                    leading: Radio<int>(
                                                      value: 0,
                                                      groupValue: selectedRadio,
                                                      onChanged: (int value) {
                                                        setState(() =>
                                                            selectedRadio =
                                                                value);
                                                      },
                                                    )),
                                                Center(
                                                  child: isload==false?RaisedButton(
                                                    child: Text("Update"),
                                                    onPressed: () async {
                                                      try{
                                                        setState(() =>
                                                        isload =
                                                        true);

                                                        if (selectedRadio == 1 &&
                                                            routeSelected ==
                                                                true) {
                                                          // get the route and bus number
                                                          SharedPreferences
                                                          prefs =
                                                          await SharedPreferences
                                                              .getInstance();
                                                          String route = prefs
                                                              .getString("route");
                                                          String busNumber = prefs
                                                              .getString("bus");
                                                     final Geolocator
                                                          geolocator =
                                                          Geolocator()
                                                            ..forceAndroidLocationManager;
                                                          var status =
                                                          await Permission
                                                              .location
                                                              .request();
                                                          if (status ==
                                                              PermissionStatus
                                                                  .granted) {
                                                            await geolocator
                                                                .getCurrentPosition(
                                                                desiredAccuracy:
                                                                LocationAccuracy
                                                                    .best)
                                                                .then((Position
                                                            position) {
                                                              setState(() {
                                                                latitude =
                                                                    position
                                                                        .latitude;
                                                                longitude =
                                                                    position
                                                                        .longitude;
                                                              });
                                                            }).catchError((e) {
                                                            });
                                                          }
                                                          var db =
                                                          FirebaseDatabase
                                                              .instance
                                                              .reference();
                                                          await prefs.setBool("externaluserId", true);
                                                          await OneSignal.shared.setExternalUserId(roll_number);
                                                          await OneSignal.shared.setSubscription(true);

                                                          await db.once().then(
                                                                  (DataSnapshot
                                                              snap) {
                                                                db
                                                                    .child(
                                                                    "Bus Routes")
                                                                    .child(route)
                                                                    .child(busNumber)
                                                                    .child(
                                                                    "Users Subscribed")
                                                                    .child(
                                                                    roll_number)
                                                                    .set({
                                                                  "Latitude":
                                                                  latitude,
                                                                  "Longitude":
                                                                  longitude
                                                                });
                                                              });
                                                          Fluttertoast.showToast(msg: "Reminder enabled successfully");
                                                        } else if (selectedRadio ==
                                                            1 &&
                                                            routeSelected ==
                                                                false) {
                                                          showDialog(
                                                              context:
                                                              this.context,
                                                              child: AlertDialog(
                                                                content: Column(
                                                                  mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                                  children: [
                                                                    Text(
                                                                        "Select a bus route and bus number to set the reminder!"),
                                                                    FlatButton(
                                                                      child: Text(
                                                                          "Ok"),
                                                                      onPressed: () =>
                                                                          Navigator.pop(
                                                                              context,
                                                                              true),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ));
                                                        } else if (selectedRadio ==
                                                            0 &&
                                                            routeSelected ==
                                                                true) {
                                                          SharedPreferences
                                                          prefs =
                                                          await SharedPreferences
                                                              .getInstance();
                                                          String route = prefs
                                                              .getString("route");
                                                          String busNumber = prefs
                                                              .getString("bus");

                                                          var db =
                                                          FirebaseDatabase
                                                              .instance
                                                              .reference();
                                                          await OneSignal.shared.setSubscription(false);
                                                          await db.once().then(
                                                                  (DataSnapshot
                                                              snap) {
                                                                db
                                                                    .child(
                                                                    "Bus Routes")
                                                                    .child(route)
                                                                    .child(busNumber)
                                                                    .child(
                                                                    "Users Subscribed")
                                                                    .child(
                                                                    roll_number)
                                                                    .remove();
                                                                Fluttertoast.showToast(msg: "Reminder disabled successfully");
                                                              });
                                                        } else if (selectedRadio ==
                                                            0 &&
                                                            routeSelected ==
                                                                false) {
                                                          showDialog(
                                                              context:
                                                              this.context,
                                                              child: AlertDialog(
                                                                content: Column(
                                                                  mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                                  children: [
                                                                    Text(
                                                                        "Select a bus route and bus number to set the reminder!"),
                                                                    FlatButton(
                                                                      child: Text(
                                                                          "Ok"),
                                                                      onPressed: () =>
                                                                          Navigator.pop(
                                                                              context,
                                                                              true),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ));
                                                        }
                                                        setState(() =>
                                                        isload =
                                                            false);
                                                      }
                                                      catch(e)
                                                      {
                                                        setState(() =>
                                                        isload =
                                                        false);

                                                        Fluttertoast.showToast(msg: "Something went wrong");
                                                      }
                                                      Navigator.pop(
                                                          context, true);
                                                    },
                                                    color: secondary,
                                                  ):CircularProgressIndicator(backgroundColor: Colors.white,),
                                                )
                                              ]);
                                        },
                                      ),
                                    );
                                  });
                            },
                            child: Card(
                              child: Center(
                                  child: Icon(
                                Icons.notifications_on_outlined,
                                size: sx(60),
                                color: primary,
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
                          height: sy(125),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BusUpdates(roll_number: roll_number,)));
                            },
                            child: Card(
                              child: Center(
                                  child: Icon(
                                Icons.directions_bus_rounded,
                                size: sx(60),
                                color: primary,
                              )),
                              color: background,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              shadowColor: secondary,
                              elevation: 3,
                            ),
                          ),
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
