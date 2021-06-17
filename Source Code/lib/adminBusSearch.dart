import 'package:bus_app/adminMap.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:relative_scale/relative_scale.dart';
class AdminBusSelection extends StatefulWidget {
  @override
  _AdminBusSelectionState createState() => _AdminBusSelectionState();
}

class _AdminBusSelectionState extends State<AdminBusSelection> {
  Color primary = Color(0xFF304FFE);
  Color secondary = Color(0xFF788Af4);
  Color background = Color(0xfffefefe);

  List<String> temp = [], busStateList = [];
  Map<dynamic, dynamic> dbValues, busValues;
  bool isload=true;
  Map<dynamic, dynamic> values;
  Iterable<dynamic> routes, buses;

  void getDataBase() async {
    List<String> routeList = [];
    var db = FirebaseDatabase.instance.reference();
    await db.once().then((DataSnapshot snap) {
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
    setState(() {
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
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Locate Bus',
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
                  'Select a Route',
                  style: TextStyle(fontSize: sy(13) > sx(13) ? sy(13) : sx(13)),
                ),
              ),

              Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: sy(10) > sx(10) ? sy(10) : sx(10))),
              isload==false?
              ListView.builder(
                shrinkWrap: true,
                primary: false,
                itemCount: temp.length,
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
                      child: Text(temp[index]),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BusSelection(
                                    route: temp[index],
                                  )));
                    },
                  );
                },
              ):Center(child: CircularProgressIndicator(backgroundColor: Colors.white,),)
            ],
          ),
        ),
      );
    });
  }
}

class BusSelection extends StatefulWidget {
  const BusSelection({Key key, @required this.route}) : super(key: key);
  final String route;

  @override
  _BusSelectionState createState() => _BusSelectionState(route: route);
}

class _BusSelectionState extends State<BusSelection> {
  _BusSelectionState({Key key, @required this.route});
  final String route;

  Color primary = Color(0xFF304FFE);
  Color secondary = Color(0xFF788Af4);
  Color background = Color(0xfffefefe);

  List<String> busStateList = [];
  Map<dynamic, dynamic> values;
  double latitude, longitude;
  Iterable<dynamic> buses;
  bool isload=true;

  void getDataBase() async {
    List<String> busList = [];
    var db = FirebaseDatabase.instance.reference();
    await db.once().then((DataSnapshot snap) {
      values = snap.value;
      values = values['Bus Routes'];
      values = values[route];
      buses = values.keys;
      buses.forEach((element) {
        busList.add(element);
      });
      setState(() {
        busStateList = busList;
        values = values;
      });
    });
    setState(() {
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
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Locate Bus',
            style: TextStyle(fontSize: sy(15) > sx(15) ? sy(15) : sx(15)),
          ),
          backgroundColor: primary,
        ),
        body: Container(
          height: screenHeight,
          width: screenWidth,
          padding: EdgeInsets.symmetric(
            vertical: sy(10),
            horizontal: sy(14),
          ),
          child: Column(
            children: [
              Container(
                child: Text(
                  'Select a Bus Number ( $route )',
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
                itemCount: busStateList.length,
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
                      child: Text(busStateList[index]),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AdminMapView(
                                  route: route,
                                  busNumber: busStateList[index])));
                    },
                  );
                },
              ):CircularProgressIndicator(backgroundColor: Colors.white,)
            ],
          ),
        ),
      );
    });
  }
}
