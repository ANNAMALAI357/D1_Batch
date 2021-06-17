import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Student_Issues extends StatefulWidget {
  @override
  _Student_IssuesState createState() => _Student_IssuesState();
}

class _Student_IssuesState extends State<Student_Issues> {
  Color primary = Color(0xFF304FFE);
  Color secondary = Color(0xFF788Af4);
  Color background = Color(0xfffefefe);

  Map<dynamic, dynamic> values, temp;
  List<String> issue_desc = [];
  var db = FirebaseDatabase.instance.reference();
  Future<List<String>> getIssues() async {
    List<String> issue_list = [];
    await db.once().then((DataSnapshot snap) {
      values = snap.value;
      values = values['Student_Issues'];
      values.keys.forEach((element) {
        if (element != 'Sample') {
          issue_list.add(element);
          temp = values[element];
          issue_desc.add(temp['Issue']);
        }
      });
    });
    return issue_list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Issues"),
        centerTitle: true,
        backgroundColor: primary,
      ),
      body: Center(
        child: FutureBuilder(
          future: getIssues(),
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return new Text('Waiting to start');
              case ConnectionState.waiting:
                return new Text('Loading...');
              default:
                if (snapshot.hasError) {
                  return new Text('Error: ${snapshot.error}');
                } else {
                  return new ListView.builder(
                      itemBuilder: (context, index) => Container(
                            margin:
                                EdgeInsets.only(top: 20, left: 30, right: 30),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(32),
                                      bottomLeft: Radius.circular(32),
                                    ),
                                    child: ListTile(
                                      title: Text(snapshot.data[index]),
                                      tileColor: secondary,
                                      onTap: () {
                                        showDialog(
                                            context: this.context,
                                            child: AlertDialog(
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(issue_desc[index]),
                                                  FlatButton(
                                                      onPressed: () {
                                                        Navigator.pop(
                                                            context, true);
                                                      },
                                                      child: Text("OK"))
                                                ],
                                              ),
                                            ));
                                      },
                                    ),
                                  ),
                                ),
                                IconButton(
                                    icon: Icon(Icons.remove_circle_outlined),
                                    onPressed: () async {
                                      await FirebaseDatabase.instance
                                          .reference()
                                          .child('Student_Issues')
                                          .child(snapshot.data[index])
                                          .remove();
                                      Fluttertoast.showToast(
                                          msg: "Issue removed successfully");
                                      setState(() {});
                                    })
                              ],
                            ),
                          ),
                      itemCount: snapshot.data.length);
                }
            }
          },
        ),
      ),
    );
  }
}
