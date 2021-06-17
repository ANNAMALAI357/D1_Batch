import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:relative_scale/relative_scale.dart';

class Help extends StatefulWidget {
  @override
  _HelpState createState() => _HelpState();
}

class _HelpState extends State<Help> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
        backgroundColor: Color.fromARGB(255,255,255,255),
        appBar: AppBar(
            backgroundColor: Color(0xFF304FFE),
            title: Text('Help'),
          centerTitle: true,
        ),
      
      /*theme: ThemeData(
        primarySwatch: Colors.blue,
      ),*/
      body: MyHelpPage(title: 'Help'),
        ),
    );
  }
}

class MyHelpPage extends StatefulWidget {
  MyHelpPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHelpPageState createState() => _MyHelpPageState();
}

class _MyHelpPageState extends State {
  bool isloading=false;
final formKey = GlobalKey<FormState>();
String roll_no;
String _message;

Color primary = Color(0xFF304FFE);
Color secondary = Color(0xFF788Af4);
Color background = Color(0xfffefefe);


  @override
  Widget build(BuildContext context) {
    return RelativeBuilder(
        builder: (context, screenHeight, screenWidth, sy, sx)
    {
      return Form(
        key: formKey,
        child: Column(

          children: [

            Padding(
              padding: const EdgeInsets.only(right: 0, left: 0),),
            Container(
                padding: EdgeInsets.all(20.0),
                margin: const EdgeInsets.only(right: 0, left: 0),
                width: sx(550),
                child: TextFormField(
                  decoration: new InputDecoration(
                    labelText: 'Roll No.',
                    labelStyle: TextStyle(
                      color: primary,
                    ),
                    prefixIcon: const Icon(
                      Icons.person,
                      color: Color(0xFF788AF4),

                    ),
                    fillColor: background,
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(25.0),
                      borderSide: const BorderSide(
                          color: Color(0xFF788AF4), width: 10.0
                      ),
                    ),
                    focusedBorder: new OutlineInputBorder (
                      borderRadius: new BorderRadius.circular(25.0),
                      borderSide: const BorderSide(color: Color(0xFF788AF4),
                      ),
                    ),
                  ),
                  validator: (val) {
                    if (val.length == 0) {
                      return 'Roll No. field should not be empty';
                    }
                    else if (val.length != 12) {
                      return 'Please enter valid Roll No.';
                    }
                    else {
                      return null;
                    }
                  },
                  onSaved: (val) => roll_no = val,

                )
            ),
            Container(
                padding: EdgeInsets.all(20.0),
                width: sx(550),
                margin: const EdgeInsets.only(right: 0, left: 0),
                child: TextFormField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Message',
                    labelStyle: TextStyle(
                      color: primary,
                    ),
                    prefixIcon: const Icon(
                      Icons.mail,
                      color: Color(0xFF788AF4),
                    ),
                    fillColor: Colors.white,
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(25.0),
                      borderSide: new BorderSide(
                      ),
                    ),
                    focusedBorder: new OutlineInputBorder (
                      borderRadius: new BorderRadius.circular(25.0),
                      borderSide: const BorderSide(color: Color(0xFF788AF4),
                      ),
                    ),
                  ),
                  validator: (val) {
                    if (val.length == 0) {
                      return 'Message field should not be empty';
                    }
                    else {
                      return null;
                    }
                  },
                  onSaved: (val) => _message = val,
                )
            ),
             isloading==false?  FractionallySizedBox(
              widthFactor: 0.5,
              child: RaisedButton(
                color: Color(0xFF304FFE),
                onPressed: () async {
                  final form = formKey.currentState;
                  if (form.validate()) {
                    form.save();
                    setState(() {
                      isloading = true;
                    });
                    try {
                      await FirebaseDatabase.instance.reference().child(
                          "Student_Issues").update(
                          {roll_no: {"Issue": _message}});
                      Fluttertoast.showToast(
                          msg: "Issue reported successfully");
                      setState(() {
                        isloading=false;
                      });
                    }

                  catch(e)
                  {
                     setState(() {
                       isloading=false;
                     });
                  }
                }},
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0),
                  side: BorderSide(color: secondary),
                ),
                child: Text(
                  'Report',
                  style: TextStyle(
                    color: Colors.white, fontSize: 15,
                  ),
                ),
              )
            ):CircularProgressIndicator(backgroundColor: Colors.blue,),
          ],
        ),
      );
    });
  }
}

