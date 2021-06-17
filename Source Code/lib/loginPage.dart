import 'dart:async';
import 'package:bus_app/admin_dashboard.dart';
import 'package:bus_app/dashboardUI.dart';
import 'package:bus_app/help.dart';
import 'package:bus_app/otp_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:relative_scale/relative_scale.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with TickerProviderStateMixin, RelativeScale {
  AnimationController controller;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _rollNumber;

  bool isLoading = false;
  String _verificationId;
  bool isbuttonVisible = false;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  Animation<double> _animationforLogo, _animationforCard;
  TextEditingController textEditingController = TextEditingController();
  @override
  void initState() {
    super.initState();

    /* Initializing all the animations used in sign in page */
    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this)
      ..repeat();
    _animationforLogo = Tween<double>(begin: 0, end: .6).animate(controller);
    _animationforCard = Tween<double>(
      begin: 0,
      end: .8,
    ).animate(controller);

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    initRelativeScaler(context);
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
      child: Stack(
        children: [
          Container(
            color: Colors.white,
          ),
          Container(
            height: sy(370),
            color: Color(4281356286),
          ),
          Scaffold(
            resizeToAvoidBottomInset: false,
            body: KeyboardAvoider(
              autoScroll: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /* App Logo here */
                  ScaleTransition(
                      scale: _animationforLogo,
                      child: Image.asset("assets/pecLogo.png")),
                  /* Form Contents here */
                  ScaleTransition(
                    scale: _animationforCard,
                    child: Container(
                      height: (sy(65) + 80) > (sx(65) + 80)
                          ? (sy(65) + 80)
                          : (sx(65) + 80),
                      width: sy(500) > sx(500) ? sy(500) : sx(500),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        color: Colors.white,
                        elevation: 10,
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.all(
                                  sy(20) > sx(20) ? sy(20) : sx(20)),
                              child: Form(
                                key: _formkey,
                                child: TextFormField(
                                  controller: textEditingController,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  maxLength: 12,
                                  onChanged: (input) {
                                    if (input.length == 12) {
                                      setState(() {
                                        isbuttonVisible = true;
                                      });
                                    } else {
                                      setState(() {
                                        isbuttonVisible = false;
                                      });
                                    }
                                  },
                                  onSaved: (input) => _rollNumber = input,
                                  textAlignVertical: TextAlignVertical.center,
                                  decoration: InputDecoration(
                                    counterText: "",
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color(4281356286)),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(50),
                                      borderSide:
                                          BorderSide(color: Color(4281356286)),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.person,
                                      color: Color(4281356286),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    labelText: "Roll Number",
                                    labelStyle:
                                        TextStyle(color: Color(4281356286)),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Sign In Button
                                  isLoading == false
                                      ? isbuttonVisible == true
                                          ? ClipOval(
                                              child: Material(
                                                color: Color(4281356286),
                                                child: InkWell(
                                                  onTap: signIn,

                                                  child: SizedBox(
                                                    height: sy(25) > sx(25)
                                                        ? sy(25)
                                                        : sx(25),
                                                    width: sy(25) > sx(25)
                                                        ? sy(25)
                                                        : sx(25),
                                                    child: Icon(
                                                      Icons
                                                          .keyboard_arrow_right_sharp,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : ClipOval(
                                              child: Material(
                                                color: Colors.black26,
                                                child: InkWell(
                                                  child: SizedBox(
                                                    height: sy(25) > sx(25)
                                                        ? sy(25)
                                                        : sx(25),
                                                    width: sy(25) > sx(25)
                                                        ? sy(25)
                                                        : sx(25),
                                                    child: Icon(
                                                      Icons
                                                          .keyboard_arrow_right_sharp,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                      : Container(
                                          height:
                                              sy(20) > sx(20) ? sy(20) : sx(20),
                                          width:
                                              sy(20) > sx(20) ? sy(20) : sx(20),
                                          child: CircularProgressIndicator(
                                            backgroundColor: Color(4281356286),
                                          )),
                                  // Help Button
                                  Container(
                                    margin: EdgeInsets.only(left: 40),
                                    child: ClipOval(
                                      child: Material(
                                        color: Color(4281356286),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Help()));
                                          },
                                          child: SizedBox(
                                            height: sy(25) > sx(25)
                                                ? sy(25)
                                                : sx(25),
                                            width: sy(25) > sx(25)
                                                ? sy(25)
                                                : sx(25),
                                            child: Icon(
                                              Icons.help,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ),
            backgroundColor: Colors.transparent,
          )
        ],
      ),
    );
  }

  Future<void> signIn() async {
    setState(() {
      isLoading = true;
    });

    final formstate = _formkey.currentState;
    formstate.save();
    _rollNumber = _rollNumber.toUpperCase();
    FocusScope.of(context).requestFocus(FocusNode());
    int newOtp = 1;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String rollNumber = await prefs.getString("RollNumber");
    String VerificationId = await prefs.getString("VerificationId");
    String phoneNumber = await prefs.getString("PhoneNumber");
    int resendToken = await prefs.getInt("ResendToken");
    String savedTime = await prefs.getString("Time");
    String username = await prefs.getString("userName");
    if (savedTime != null) {
      newOtp = 0;
      final time = DateTime.parse(savedTime);

      if ((!(time.difference(DateTime.now()).isNegative)) &&
          (_rollNumber == rollNumber)) {
        Fluttertoast.showToast(
            msg: "Enter your recently sent OTP",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Otp(
                      verificationId: VerificationId,
                      mobile: phoneNumber,
                      resendToken: resendToken,
                      rollNumber: _rollNumber,
                      username: username,
                    )));
      } else {
        newOtp = 1;
        await prefs.remove("RollNumber");
        await prefs.remove("VerificationId");
        await prefs.remove("PhoneNumber");
        await prefs.remove("ResendToken");
        await prefs.remove("Time");
      }
    }
    if (newOtp == 1) {
      Map<dynamic, dynamic> values, adminLogins, studentLogins, userMobile;
      var db = FirebaseDatabase.instance.reference();
      await db.once().then((DataSnapshot snap) {
        values = snap.value;
        values = values['LoginDetails'];
        adminLogins = values['Admin Access'];
        studentLogins = values['Student'];
      });

      if (adminLogins.containsKey(_rollNumber)) {
        String number = adminLogins[_rollNumber].toString();
        await prefs.setString("userName", "ADMIN");
        await verifyPhoneNumber(number, _rollNumber, "ADMIN");
      } else if (studentLogins.containsKey(_rollNumber)) {
        userMobile = studentLogins[_rollNumber];
        String number = userMobile["Mobile"];
        String userName = userMobile["Name"];
        await prefs.setString("userName", userName);
        await verifyPhoneNumber(number, _rollNumber, userName);
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
            msg: "Unknown Login credentials",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.lightBlue,
            textColor: Colors.black,
            fontSize: 16.0);
      }
    }
  }

  void verifyPhoneNumber(
      String number, String rollNumber, String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    void showSnackbar(String message) {
      Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_LONG);
    }

    PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential phoneAuthCredential) async {
      await _auth.signInWithCredential(phoneAuthCredential);
      setState(() {
        isLoading = false;
      });
      showSnackbar("Phone number automatically verified");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("userId", _rollNumber);
      await prefs.setString("userName", userName);
      if (userName == "ADMIN") {
        await prefs.setBool("accessLevel", true);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => AdminDashboard()));
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DashBoardUI(
                    routeSelected: false, roll_number: _rollNumber)));
      }
    };
    PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      showSnackbar(
          'Phone number verification failed. ${authException.message}');
      setState(() {
        isLoading = false;
      });
    };
    PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      showSnackbar('Please check your phone for the verification code.');
      _verificationId = verificationId;
      await prefs.setString("VerificationId", verificationId);
      await prefs.setString("RollNumber", _rollNumber);
      await prefs.setInt("ResendToken", forceResendingToken);
      await prefs.setString(
          "Time", DateTime.now().add(Duration(minutes: 5)).toString());
      await prefs.setString("PhoneNumber", number);
      setState(() {
        isLoading = false;
      });
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Otp(
                    verificationId: _verificationId,
                    mobile: number,
                    resendToken: forceResendingToken,
                    rollNumber: _rollNumber,
                    username: userName,
                  )));
    };
    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
    };
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: number,
        timeout: const Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } catch (e) {
      showSnackbar("Failed to Verify Phone Number:");
      setState(() {
        isLoading = false;
      });
    }
  }
}
