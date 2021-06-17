import 'package:bus_app/admin_dashboard.dart';
import 'package:bus_app/loginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboardUI.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _debugLabelString = "";
  String _emailAddress;
  String _externalUserId;
  bool _enableConsentButton = false;

  // CHANGE THIS parameter to true if you want to test GDPR privacy consent
  bool _requireConsent = true;
  @override
  void initState() {

    super.initState();
    initPlatformState();
    Future<void> main_function() async{
      try {
        WidgetsFlutterBinding.ensureInitialized();
        await Firebase.initializeApp();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool routeSelected =
        await prefs.getBool("routeSelected") == null ? false : true;
        String userId = await prefs.getString("userId");
        bool isAdmin = await prefs.getBool("accessLevel");
        bool new_login = await prefs.getBool("new_user");
        bool externaluserId = await prefs.getBool("externaluserId");
        final FirebaseAuth _auth = FirebaseAuth.instance;
        int authcheck;
      try {
        authcheck = _auth.currentUser.phoneNumber.length;
      } catch (e) {
        if(externaluserId==true) {
          await prefs.remove("externaluserId");
          await OneSignal.shared.removeExternalUserId();
        }
        authcheck = 0;
      }

      runApp(MaterialApp(
          home: authcheck == 0 && userId == null
              ? LoginPage()
              : isAdmin == true
              ? AdminDashboard()
              : DashBoardUI(
              routeSelected: routeSelected, roll_number: userId)));
      }
      catch(E)
      {
        Fluttertoast.showToast(msg: "Check your internet connection");
      }
    }
    main_function();
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;

    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    var settings = {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.promptBeforeOpeningPushUrl: true
    };

    OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) {
      this.setState(() {
        _debugLabelString =
        "Received notification: \n${notification.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
    });

    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      this.setState(() {
        _debugLabelString =
        "Opened notification: \n${result.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
    });

    OneSignal.shared
        .setInAppMessageClickedHandler((OSInAppMessageAction action) {
      this.setState(() {
        _debugLabelString =
        "In App Message Clicked: \n${action.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
    });

    OneSignal.shared
        .setSubscriptionObserver((OSSubscriptionStateChanges changes) {
      print("SUBSCRIPTION STATE CHANGED: ${changes.jsonRepresentation()}");
    });

    OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
      print("PERMISSION STATE CHANGED: ${changes.jsonRepresentation()}");
    });

    OneSignal.shared.setEmailSubscriptionObserver(
            (OSEmailSubscriptionStateChanges changes) {
          print("EMAIL SUBSCRIPTION STATE CHANGED ${changes.jsonRepresentation()}");
        });

    await OneSignal.shared
        .init("your app id", iOSSettings: settings);

    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);


  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color:  Color(4281356286),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            child: Image.asset("assets/pecLogo.png"),
          ),
          CircularProgressIndicator(backgroundColor: Colors.white)
        ],
      ),
    );
  }
}
