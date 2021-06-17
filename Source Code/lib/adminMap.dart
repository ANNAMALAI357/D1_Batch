import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AdminMapView extends StatefulWidget {
  const AdminMapView({Key key, @required this.route, @required this.busNumber})
      : super(key: key);
  final String route;
  final String busNumber;

  @override
  State<AdminMapView> createState() =>
      _AdminMapViewState(route: route, busNumber: busNumber);
}

class _AdminMapViewState extends State<AdminMapView> {
  _AdminMapViewState({Key key, @required this.route, @required this.busNumber});
  final String route;
  final String busNumber;

  Completer<GoogleMapController> _controller = Completer();
  static double Lat = 11.127;
  static double Lng = 78.6569;
  static double zoomLevel = 14;

  Map<dynamic, dynamic> values;
  var db = FirebaseDatabase.instance.reference();

  Marker marker;
  Circle circle;

  CameraPosition _busPosition = CameraPosition(
    bearing: 192.8334901395799,
    target: LatLng(Lat, Lng),
    zoom: zoomLevel,
  );
  Timer timer;

  @override
  void initState() {
    super.initState();
    Future<int> check_not_null=_initialTrackBus();
    check_not_null.then((value) {
      if (value == 1)
        timer = Timer.periodic(Duration(seconds: 2), (timer) => _findmyBus());
      else {
        Fluttertoast.showToast(msg: "Bus is not moving at this time");
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  Future<Uint8List> getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/busMarker.png");
    return byteData.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
        markers: Set.of((marker != null) ? [marker] : []),
        circles: Set.of((circle != null) ? [circle] : []),
        initialCameraPosition: _busPosition,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }

  void updateMarker(LatLng location, Uint8List imageData) {
    setState(() {
      marker = Marker(
          markerId: MarkerId("Bus"),
          position: location,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));

      circle = Circle(
          circleId: CircleId("car"),
          radius: 200,
          zIndex: 1,
          strokeColor: Colors.blue,
          strokeWidth: 2,
          center: location,
          fillColor: Colors.blue.withAlpha(50));
    });
  }

  Future<void> _findmyBus() async {
    final GoogleMapController controller = await _controller.future;
    var db = FirebaseDatabase.instance.reference();
    await db.once().then((DataSnapshot snap) {
      values = snap.value;
      values = values['Bus Routes'];
      values = values[route];
      values = values[busNumber];
      double aPos = values['Latitude'];
      double bPos = values['Longitude'];
      setState(() {
        Lat = aPos;
        Lng = bPos;
      });
    });
    await controller.getZoomLevel().then((value) {
      zoomLevel = value;
    });

    CameraPosition _busPosition1 = CameraPosition(
      target: LatLng(Lat, Lng),
      zoom: zoomLevel,
    );

    Uint8List imageData = await getMarker();
    updateMarker(LatLng(Lat, Lng), imageData);
    controller.animateCamera(CameraUpdate.newCameraPosition(_busPosition1));
  }
  Future<int> _initialTrackBus() async {
    var db = FirebaseDatabase.instance.reference();
    int result=0;
    await db.once().then((DataSnapshot snap) {
      values = snap.value;
      values = values['Bus Routes'];
      values = values[route];
      values = values[busNumber];
      if(values['Latitude'].runtimeType==double)
        {
          result=1;
        }
    });
    return Future.value(result);
  }
}
