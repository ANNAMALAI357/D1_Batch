import 'package:bus_app/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

Future<void> main() async {

  runApp(MaterialApp(title: "Find My Bus",home: SplashScreen(),));
}

