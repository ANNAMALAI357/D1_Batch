import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:relative_scale/relative_scale.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_dashboard.dart';
import 'dashboardUI.dart';

class Otp extends StatefulWidget {
  const Otp({Key key, @required this.verificationId,@required this.mobile,@required this.resendToken, @required this.rollNumber,@required this.username}) : super(key: key);
  final String verificationId,mobile, rollNumber,username;
  final int resendToken;
  @override
  _OtpState createState() => _OtpState(verificationId: verificationId,mobile: mobile,resendToken: resendToken, rollNumber: rollNumber,username: username);
}

class _OtpState extends State<Otp> {

  _OtpState({Key key, @required this.verificationId,@required this.mobile,@required this.resendToken, @required this.rollNumber,@required this.username});
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String verificationId, mobile, rollNumber,username;
  int resendToken;
  Color primary = Color(0xFF304FFE);
  Color secondary = Color(0xFF788Af4);
  Color background = Color(0xfffefefe);
  Color otp = Color.fromRGBO(48, 79, 254, .1);
  Color otpBorder = Color.fromRGBO(231, 239, 246, .7);

  FocusNode pin2FocusNode;
  FocusNode pin3FocusNode;
  FocusNode pin4FocusNode;
  FocusNode pin5FocusNode;
  FocusNode pin6FocusNode;

  int secondsLeft = 0;
  int secondsRight = 0;
  int minute = 1;
  bool resend = false;

  Timer _timer;

  String OTP = '';
  final textController1 = TextEditingController();
  final textController2 = TextEditingController();
  final textController3 = TextEditingController();
  final textController4 = TextEditingController();
  final textController5 = TextEditingController();
  final textController6 = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void nextField({String value, FocusNode focusNode}) {
    if (value.length == 1) {
      focusNode.requestFocus();
    }
  }
  void signInWithPhoneNumber(String _otp) async{
    void showSnackbar(String message) {
      Fluttertoast.showToast(msg: message);
    }
    try {

      showSnackbar("Successfully signed in");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove("RollNumber");
      await prefs.remove("VerificationId");
      await prefs.remove("PhoneNumber");
      await prefs.remove("ResendToken");
      await prefs.remove("Time");
      await prefs.setString("userId", rollNumber);
      await prefs.setString("userName", username);
      if(username=="ADMIN")
      {
        await prefs.setBool("accessLevel", true);
        Navigator.push(context, MaterialPageRoute(builder: (context) =>
            AdminDashboard()));
      }
      else
      {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>DashBoardUI(routeSelected: false, roll_number: rollNumber)));

      }
     } catch (e) {
      showSnackbar("Failed to sign in: " + e.toString());
      AlertDialog alert = AlertDialog(
        title: Text('Login Error'),
        content: Text(e.toString()),
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }
  }

  void validateOtp(val) {
    if (val.length == 6) {
        signInWithPhoneNumber(OTP);

    } else {
      {
        AlertDialog alert = AlertDialog(
          title: Text('Data Invalid'),
          content: Text('Enter a valid OTP!'),
        );
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          },
        );
      }
    }
  }

  void validationHandler() {
    AlertDialog alert = AlertDialog(
      title: Text('Data Invalid'),
      content: Text('OTP must be a number'),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (minute == 1) {
          minute--;
          secondsLeft = 5;
          secondsRight = 9;
        } else {
          if (secondsRight == 0 && secondsLeft == 0) {
            setState(() {
              resend = true;
            });
            _timer.cancel();
          } else {
            if (secondsRight == 0) {
              secondsLeft--;
              secondsRight = 9;
            } else {
              secondsRight--;
            }
          }
        }
      });
    });
  }

  void resendCodeHandler(String number) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    void showSnackbar(String message) {
      Fluttertoast.showToast(msg: message,toastLength:Toast.LENGTH_LONG);
    }
    PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential phoneAuthCredential) async {
      await _auth.signInWithCredential(phoneAuthCredential);
      showSnackbar("Phone number automatically verified");

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("userId", rollNumber);
      await prefs.setString("userName", username);
      if(username=="ADMIN")
      {
        await prefs.setBool("accessLevel", true);
        Navigator.push(context, MaterialPageRoute(builder: (context) =>
            AdminDashboard()));
      }
      else
      {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>DashBoardUI(routeSelected: false, roll_number: rollNumber)));

      }



    };
    PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      showSnackbar('Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
    };

    PhoneCodeSent codeSent =
        (String VerificationId, [int forceResendingToken]) async {
      showSnackbar('Please check your phone for the verification code.');
      verificationId=VerificationId;
      await prefs.remove("VerificationId");
      await prefs.remove("ResendToken");
      await prefs.remove("Time");

      await prefs.setString("VerificationId",verificationId);
      setState(() {
        resendToken=forceResendingToken;
      });
      await prefs.setInt("ResendToken", forceResendingToken);
      await prefs.setString("Time",DateTime.now().add(Duration(minutes: 5)).toString());

    };
    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {

    };
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: number,
        timeout: const Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        forceResendingToken: resendToken
      );
      startTimer();

    } catch (e) {

      showSnackbar("Failed to Verify Phone Number: ${e}");

    }

  }

  void onPressHandler() {
    if (resend) {
      minute = 1;
      secondsLeft = 0;
      secondsRight = 0;
      setState(() {
        resend = false;
      });
      resendCodeHandler(mobile);

    }
  }

  @override
  void initState() {
    super.initState();
    startTimer();
    pin2FocusNode = FocusNode();
    pin3FocusNode = FocusNode();
    pin4FocusNode = FocusNode();
    pin5FocusNode = FocusNode();
    pin6FocusNode = FocusNode();
    textController1.addListener(() { OTP = ""; });
    textController2.addListener(() { OTP = ""; });
    textController3.addListener(() { OTP = ""; });
    textController4.addListener(() { OTP = ""; });
    textController5.addListener(() { OTP = ""; });
    textController6.addListener(() { OTP = ""; });
  }

  void dispose() {

    _timer.cancel();
    pin2FocusNode.dispose();
    pin3FocusNode.dispose();
    pin4FocusNode.dispose();
    pin5FocusNode.dispose();
    pin6FocusNode.dispose();
    textController1.dispose();
    textController2.dispose();
    textController3.dispose();
    textController4.dispose();
    textController5.dispose();
    textController6.dispose();
    super.dispose();
  }

  bool _isNumeric(String val) {
    return double.tryParse(val) != null;
  }

  @override
  Widget build(BuildContext context) {
    return RelativeBuilder(
        builder: (context, screenHeight, screenWidth, sy, sx) {
          return Scaffold(
            resizeToAvoidBottomPadding: false,
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                'Verify',
                style: TextStyle(fontSize: sy(15) > sx(15) ? sy(15) : sx(15)),
              ),
              backgroundColor: primary,
            ),
            body: Container(
              height: screenHeight,
              width: screenWidth,
              color: background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: ListView(
                      children: [
                        Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: sy(25) > sx(25) ? sy(25) : sx(25))),
                        Image.asset(
                          'assets/user-interface.png',
                          width: sy(75) > sx(75) ? sy(75) : sx(75),
                          height: sy(75) > sx(75) ? sy(75) : sx(75),
                        ),
                        Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: sy(15) > sx(15) ? sy(15) : sx(15))),
                        Container(
                          color: background,
                          child: Column(
                            children: [
                              Container(
                                width: sx(300) < sy(300) ? sx(300) : sy(300),
                                child: Text(
                                  'OTP has been sent to you on your mobile phone. Please enter it below.',
                                  style: TextStyle(
                                      fontSize: sy(12) > sx(12) ? sy(12) : sx(12)),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 0,
                                      vertical: sy(10) > sx(10) ? sy(10) : sx(10))
                              ),
                              Form(
                                key: _formKey,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: sy(32) > sx(32) ? sy(32) : sx(32),
                                      height: sy(32) > sx(32) ? sy(32) : sx(32),
                                      margin: EdgeInsets.symmetric(
                                          horizontal: sx(6), vertical: 0),
                                      child: TextFormField(
                                        style: TextStyle(
                                            fontSize:
                                            sy(16) > sx(16) ? sy(16) : sx(16),
                                            color: secondary
                                        ),
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value.isNotEmpty) {
                                            if(!_isNumeric(value)) {
                                              validationHandler();
                                            }
                                          }
                                          return null;
                                        },
                                        textAlign: TextAlign.center,
                                        cursorColor: secondary,
                                        controller: textController1,
                                        decoration: InputDecoration(
                                          fillColor: otp,
                                          filled: true,
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              color: otpBorder,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                    48, 79, 254, .2)),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          if (  _formKey.currentState.validate()) {
                                            nextField(
                                                value: value,
                                                focusNode: pin2FocusNode);
                                          }

                                        },
                                      ),
                                    ),
                                    Container(
                                      width: sy(32) > sx(32) ? sy(32) : sx(32),
                                      height: sy(32) > sx(32) ? sy(32) : sx(32),
                                      margin: EdgeInsets.symmetric(
                                          horizontal: sx(6), vertical: 0),
                                      child: TextFormField(
                                        focusNode: pin2FocusNode,
                                        style: TextStyle(
                                          fontSize:
                                          sy(16) > sx(16) ? sy(16) : sx(16),
                                          color: secondary,
                                        ),
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value.isNotEmpty) {
                                            if(!_isNumeric(value)) {
                                              validationHandler();
                                            }
                                          }
                                          return null;
                                        },
                                        textAlign: TextAlign.center,
                                        cursorColor: secondary,
                                        controller: textController2,
                                        decoration: InputDecoration(
                                          fillColor: otp,
                                          filled: true,
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                color: otpBorder,
                                              )),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                    48, 79, 254, .2)),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          if (  _formKey.currentState.validate()) {
                                            nextField(
                                                value: value,
                                                focusNode: pin3FocusNode);
                                          }
                                        },
                                      ),
                                    ),
                                    Container(
                                      width: sy(32) > sx(32) ? sy(32) : sx(32),
                                      height: sy(32) > sx(32) ? sy(32) : sx(32),
                                      margin: EdgeInsets.symmetric(
                                          horizontal: sx(6), vertical: 0),
                                      child: TextFormField(
                                        focusNode: pin3FocusNode,
                                        style: TextStyle(
                                          color: secondary,
                                          fontSize:
                                          sy(16) > sx(16) ? sy(16) : sx(16),),
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value.isNotEmpty) {
                                            if(!_isNumeric(value)) {
                                              validationHandler();
                                            }
                                          }
                                          return null;
                                        },
                                        textAlign: TextAlign.center,
                                        cursorColor: secondary,
                                        controller: textController3,
                                        decoration: InputDecoration(
                                          fillColor: otp,
                                          filled: true,
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                color: otpBorder,
                                              )),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                    48, 79, 254, .2)),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          if (  _formKey.currentState.validate()) {
                                            nextField(
                                                value: value,
                                                focusNode: pin4FocusNode);
                                          }
                                        },
                                      ),
                                    ),
                                    Container(
                                      width: sy(32) > sx(32) ? sy(32) : sx(32),
                                      height: sy(32) > sx(32) ? sy(32) : sx(32),
                                      margin: EdgeInsets.symmetric(
                                          horizontal: sx(6), vertical: 0),
                                      child: TextFormField(
                                        focusNode: pin4FocusNode,
                                        style: TextStyle(
                                          color: secondary,
                                          fontSize:
                                          sy(16) > sx(16) ? sy(16) : sx(16),),
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value.isNotEmpty) {
                                            if(!_isNumeric(value)) {
                                              validationHandler();
                                            }
                                          }
                                          return null;
                                        },
                                        textAlign: TextAlign.center,
                                        cursorColor: secondary,
                                        controller: textController4,
                                        decoration: InputDecoration(
                                          fillColor: otp,
                                          filled: true,
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                color: otpBorder,
                                              )),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                    48, 79, 254, .2)),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          if (  _formKey.currentState.validate()) {
                                            nextField(
                                                value: value,
                                                focusNode: pin5FocusNode);
                                          }
                                        },
                                      ),
                                    ),
                                    Container(
                                      width: sy(32) > sx(32) ? sy(32) : sx(32),
                                      height: sy(32) > sx(32) ? sy(32) : sx(32),
                                      margin: EdgeInsets.symmetric(
                                          horizontal: sx(6), vertical: 0),
                                      child: TextFormField(
                                        focusNode: pin5FocusNode,
                                        style: TextStyle(
                                          color: secondary,
                                          fontSize:
                                          sy(16) > sx(16) ? sy(16) : sx(16),),
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value.isNotEmpty) {
                                            if(!_isNumeric(value)) {
                                              validationHandler();
                                            }
                                          }
                                          return null;
                                        },
                                        textAlign: TextAlign.center,
                                        cursorColor: secondary,
                                        controller: textController5,
                                        decoration: InputDecoration(
                                          fillColor: otp,
                                          filled: true,
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                color: otpBorder,
                                              )),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                    48, 79, 254, .2)),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          if (  _formKey.currentState.validate()) {
                                            nextField(
                                                value: value,
                                                focusNode: pin6FocusNode);
                                          }
                                        },
                                      ),
                                    ),
                                    Container(
                                      width: sy(32) > sx(32) ? sy(32) : sx(32),
                                      height: sy(32) > sx(32) ? sy(32) : sx(32),
                                      margin: EdgeInsets.symmetric(
                                          horizontal: sx(6), vertical: 0),
                                      child: TextFormField(
                                        focusNode: pin6FocusNode,
                                        style: TextStyle(
                                          color: secondary,
                                          fontSize:
                                          sy(16) > sx(16) ? sy(16) : sx(16),),
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value.isNotEmpty) {
                                            if(!_isNumeric(value)) {
                                              validationHandler();
                                            }
                                          }
                                          return null;
                                        },
                                        textAlign: TextAlign.center,
                                        cursorColor: secondary,
                                        controller: textController6,
                                        decoration: InputDecoration(
                                          fillColor: otp,
                                          filled: true,
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                color: otpBorder,
                                              )),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                    48, 79, 254, .2)),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          if (  _formKey.currentState.validate()) {

                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 0,
                                      vertical: sy(8) > sx(8) ? sy(8) : sx(8))),
                              FlatButton(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 20),
                                textColor: primary,
                                color: background,
                                child: Text(
                                  'Verify',
                                  style: TextStyle(
                                      fontSize: sy(12) > sx(12) ? sy(12) : sx(12)),
                                ),
                                onPressed: () => {
                                  OTP += textController1.text,
                                  OTP += textController2.text,
                                  OTP += textController3.text,
                                  OTP += textController4.text,
                                  OTP += textController5.text,
                                  OTP += textController6.text,

                                  pin2FocusNode.unfocus(),
                                  pin3FocusNode.unfocus(),
                                  pin4FocusNode.unfocus(),
                                  pin5FocusNode.unfocus(),
                                  pin6FocusNode.unfocus(),
                                  validateOtp(OTP),
                                },
                              ),
                              Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 0,
                                      vertical: sy(10) > sx(10) ? sy(10) : sx(10))),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    child: Text(
                                      'Didn\'t receive code?  ',
                                      style: TextStyle(
                                          fontSize:
                                          sy(12) > sx(12) ? sy(12) : sx(12)),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                      '$minute:$secondsLeft$secondsRight',
                                      style: TextStyle(
                                          fontSize:
                                          sy(12) > sx(12) ? sy(12) : sx(12),
                                          color: primary),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              resend == true
                                  ? FlatButton(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 20),
                                textColor: secondary,
                                color: background,
                                child: Text(
                                  'Resend Code',
                                  style: TextStyle(
                                      fontSize:
                                      sy(12) > sx(12) ? sy(12) : sx(12)),
                                ),
                                onPressed: () => onPressHandler(),
                              )
                                  : FlatButton(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 20),
                                textColor: secondary,
                                color: background,
                                child: Text(
                                  'Resend Code',
                                  style: TextStyle(
                                      fontSize:
                                      sy(12) > sx(12) ? sy(12) : sx(12)),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}



