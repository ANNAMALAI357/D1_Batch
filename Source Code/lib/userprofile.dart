import 'package:bus_app/routeSelection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'loginPage.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  List<String> temp = ['Select any route'], busStateList = ['Select Your Bus'];
  String dropDownValue = 'Select any route';
  String busDropDown = 'Select Your Bus';

  Color primary = Color(0xFF304FFE); 
  Color secondary = Color(0xFF788Af4);
  Color background = Color(0xfffefefe);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isload=false;

  String local_routename, local_route;

  Map<dynamic, dynamic> dbValues, busValues;
  bool routeSelected = false;
  List<String> routeList = ['Select any route'];
  Map<dynamic, dynamic> values;
  Iterable<dynamic> routes, buses;
  String bus, route;

  loadUserdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    local_routename = await prefs.getString("route");
    local_route = await prefs.getString("bus");
    routeSelected = await prefs.getBool("routeSelected");
    if (routeSelected == null || routeSelected == false) {
      local_route = "No Route selected";
      local_routename = "No Route selected";
    }

    var db = FirebaseDatabase.instance.reference();
    await db.once().then((DataSnapshot snap) {
      values = snap.value;
      values = values['Bus Routes'];
      routes = values.keys;
      routes.forEach((element) {
        if (!routeList.contains(element)) routeList.add(element);
      });
      temp = routeList;
      dbValues = values;
    });
    return "Done Processing";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Profile"),
        backgroundColor: primary,
      ),
      body: Center(
        child: FutureBuilder(
          future: loadUserdata(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return new Text('Waiting to start');
              case ConnectionState.waiting:
                return new Text('Loading...');
              default:
                if (snapshot.hasError) {
                  return new Text('Error: ${snapshot.error}');
                } else {
                  return Center(
                    child: Column(
                      children: [
                        Material(
                          elevation: 4.0,
                          shape: CircleBorder(),
                          clipBehavior: Clip.hardEdge,
                          color: Colors.transparent,
                          child: Ink.image(
                            image: AssetImage('assets/user.png'),
                            fit: BoxFit.cover,
                            width: 120.0,
                            height: 120.0,
                            child: InkWell(
                              onTap: () {},
                            ),
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.only(top: 20),
                            child: Text(
                              "Your Route is: $local_routename",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            )),
                        Container(
                            margin: EdgeInsets.only(top: 20),
                            child: Text(
                              "Your Bus number is: $local_route",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            )),
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          child: RaisedButton(
                            color: primary,
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RouteSelection()));
                            },
                            child: Text("Edit" ,style: TextStyle(color: Colors.white),),
                          ),
                        ),
                        Container(
                            child: Center(
                          child: isload==false? RaisedButton(
                            color: primary,
                            child: Text("Logout" ,style: TextStyle(color: Colors.white),),
                            onPressed: () async {
                              try{
                                setState(() {
                                  isload=true;
                                });
                                await OneSignal.shared.setSubscription(false);
                                await OneSignal.shared.removeExternalUserId();
                                await _auth.signOut();
                                SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                                await prefs.clear();
                                setState(() {
                                  isload=false;
                                });
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginPage()));
                              }
                              catch(e)
                              {
                                Fluttertoast.showToast(msg: "Something went wrong");
                              }
                            },
                          ):CircularProgressIndicator(backgroundColor: Colors.white),
                        ))
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                  );
                }
            }
          },
        ),
      ),
    );
  }
}
