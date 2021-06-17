import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BusUpdates extends StatefulWidget {
  const BusUpdates(
      {Key key, @required this.roll_number})
      : super(key: key);
  final String roll_number;
  @override
  _BusUpdatesState createState() => _BusUpdatesState(roll_number: roll_number);
}

class _BusUpdatesState extends State<BusUpdates> {

  _BusUpdatesState(
      {Key key, @required this.roll_number});
  final String roll_number;

  Map<dynamic, dynamic> values,temp;
  List<String> notifications = [];
  var db = FirebaseDatabase.instance.reference();

  Color primary = Color(0xFF304FFE);
  Color secondary = Color(0xFF788Af4);
  Color background = Color(0xfffefefe);

  Future<List<String>> getNotifications() async {
    List<String> notificationlist = [];
    await db.once().then((DataSnapshot snap) {
      values = snap.value;
      values = values['LoginDetails'];
      values = values['Student'];
      values = values[roll_number];
      values = values['Your Notifications'];
      values.keys.forEach((element) {
        if(element!='Dummy')
        {
          notificationlist.add(element);
          notifications.add(values[element]);
        }
      });

    });
    return notificationlist;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bus Updates"),
        backgroundColor: primary,
        centerTitle: true,
      ),
      body: Center(
        child: FutureBuilder(
          future: getNotifications(),
          builder:
              (BuildContext context, AsyncSnapshot<List> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return new Text('Waiting to start');
              case ConnectionState.waiting:
                return new Text('Loading...');
              default:
                if (snapshot.hasError) {
                  return new Text('Error: ${snapshot.error}');
                } else {
                    if(notifications.length == 0) {
                      return Container(
                        child: Center(
                          child: Text("No new updates"),
                        ),
                      );
                    }
                   return new ListView.builder(

                      itemBuilder: (context, index) =>
                          Container(
                            margin: EdgeInsets.only(top: 20,left: 30,right: 30),
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
                                      title: Text(
                                        notifications[index], style: TextStyle(color: background),
                                      ),
                                      tileColor: secondary,

                                    ),
                                  ),
                                ),
                                IconButton(icon: Icon(Icons.remove_circle_outlined), onPressed: ()async{
                                  await FirebaseDatabase.instance.reference()
                                      .child('LoginDetails').child('Student')
                                      .child(roll_number).child('Your Notifications')
                                      .child(snapshot.data[index])
                                      .remove();
                                  Fluttertoast.showToast(msg: "Notification removed successfully");
                                  setState(() {
                                    notifications.removeAt(index);
                                  });
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

