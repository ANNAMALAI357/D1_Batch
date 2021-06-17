import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:relative_scale/relative_scale.dart';

class ManualBusUpload extends StatefulWidget {
  @override
  _ManualBusUploadState createState() => _ManualBusUploadState();
}

class _ManualBusUploadState extends State<ManualBusUpload> {
  Color primary = Color(0xFF304FFE);
  Color secondary = Color(0xFF788Af4);
  Color background = Color(0xfffefefe);
  bool isload=false;

  String route, busNumber;

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  var db = FirebaseDatabase.instance.reference();
  Map<dynamic, dynamic> values;

  @override
  Widget build(BuildContext context) {
    return RelativeBuilder(
        builder: (context, screenHeight, screenWidth, sy, sx) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Upload Bus Information"),
          centerTitle: true,
          backgroundColor: primary,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formkey,
              child: Container(
                height: sy(300),
                width: sx(400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        margin: EdgeInsets.only(bottom: 15),
                        child: Image.asset(
                          'assets/pecLogo.png',
                          height: sy(100),
                          fit: BoxFit.cover,
                        )),
                    Flexible(
                      flex: 3,
                      child: TextFormField(
                        keyboardType: TextInputType.name,
                        onChanged: (input) => route = input,
                        validator: (input) {
                          if (input.length == 0) {
                            return "Route cannot be empty";
                          }
                        },
                        cursorColor: secondary,
                        decoration: InputDecoration(
                          labelText: "Route",
                          focusColor: secondary,
                          labelStyle: TextStyle(
                            color: primary,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: secondary,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Color.fromRGBO(48, 79, 254, .2)),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Color.fromRGBO(48, 79, 254, .2)),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Color.fromRGBO(48, 79, 254, .2)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Flexible(
                      flex: 3,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        onChanged: (input) => busNumber = input,
                        validator: (input) {
                          if (input.length == 0 && input.length < 10) {
                            return "Bus Number cannot be empty";
                          }
                        },
                        cursorColor: secondary,
                        decoration: InputDecoration(
                          labelText: "Bus Number",
                          focusColor: secondary,
                          labelStyle: TextStyle(
                            color: primary,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: secondary,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Color.fromRGBO(48, 79, 254, .2)),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Color.fromRGBO(48, 79, 254, .2)),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Color.fromRGBO(48, 79, 254, .2)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    isload==false?RaisedButton(
                      child: Text(
                        "Upload",
                        style: TextStyle(color: background),
                      ),
                      color: primary,
                      onPressed: () async {
                        setState(() {
                          isload = true;
                        });
                        await db.once().then((DataSnapshot snap) {
                          values = snap.value;
                          values = values['Bus Routes'];
                        });
                        if (_formkey.currentState.validate()) {
                          Fluttertoast.showToast(msg: "Uploading data");
                          await db
                              .child("Bus Routes")
                              .child(route.trim())
                              .child(busNumber.trim())
                              .set({
                            "Bus Status": "Not Moving",
                            "Latitude": "xxx",
                            "Longitude": "xxx",
                            "Route Change": "No"
                          });
                          setState(() {
                            isload=false;
                          });

                          Fluttertoast.showToast(
                              msg: "Data uploaded successfully");
                        }
                        else{
                          setState(() {
                            isload = false;
                          });
                        }
                      },
                    ):CircularProgressIndicator(backgroundColor: Colors.white,)
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
