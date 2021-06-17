import 'dart:async';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:excel/excel.dart';
import 'package:relative_scale/relative_scale.dart';

class MyFiles extends StatefulWidget {
  @override
  _MyFilesState createState() => _MyFilesState();
}

class _MyFilesState extends State<MyFiles> {
  var missingValue, validData;
  var actionNeeded = [];
  // Roll numbers with missing or invalid data are added to it
  var phone, phoneLen;
  var countryCode = "+91";

  Color primary = Color(0xFF304FFE);
  Color secondary = Color(0xFF788Af4);
  Color background = Color(0xfffefefe);

  Future<void> readXlsx(path) async {
    var file = path;
    var bytes = File(file).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes); // read the excel file

    Map<dynamic, dynamic> values;
    var db = FirebaseDatabase.instance.reference();
    await db.once().then((DataSnapshot snap) {
      values = snap.value;
      values = values['LoginDetails'];
      values = values['Student'];
    });

    for (var table in excel.tables.keys) {
      Fluttertoast.showToast(msg: "Uploading Data");
      var title =
          excel.tables[table].rows[0]; // access the header of excel sheet
      var hasName = title.contains("Name"); // check for required files
      var hasRollNo = title.contains("Roll Number");
      var hasPhone = title.contains("Phone Number");
      if (hasName && hasRollNo && hasPhone) {
        // if all present
        var phoneIndex = title.indexOf("Phone Number");
        var rollNoIndex = title.indexOf("Roll Number");
        var nameIndex = title.indexOf("Name");
        var data = excel.tables[table].rows
            .sublist(1); // accessing the content of excel sheet
        for (var row in data) {
          // for each row in excel sheet except header
          missingValue =
              false; // initialize as no missing values present in the row
          validData =
              true; // initialized as valid data - phone numbers are of length 10 & Roll no = 12
          if (row.contains(null)) {
            // check for missing values
            missingValue = true;
            actionNeeded.add(row[rollNoIndex]);
          } else {
            // if no missing values present
            phoneLen = row[phoneIndex].toString().length - 2;

            phone = row[phoneIndex].toString().substring(0, phoneLen);
            if (phone.length != 10 ||
                row[rollNoIndex].toString().length != 12) {
              // check length of phone number && Roll number
              validData = false; // data to be uploaded only if true
              actionNeeded.add(row[rollNoIndex]);
            } else {
              phone = countryCode + phone;
            }
          }
          if (!missingValue && validData) {
            // if no missing data and for valid data, add to db
            await db
                .child("LoginDetails/Student")
                .child(row[rollNoIndex])
                .set({"Name": row[nameIndex], "Mobile": phone});
            await db
                .child("LoginDetails/Student")
                .child(row[rollNoIndex])
                .child("Your Notifications")
                .set({"Dummy": "notification"});
          }
        }
        Fluttertoast.showToast(msg: "Data Uploaded");
        if (actionNeeded.isNotEmpty == true) {
          return showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error : Failed to Upload'),
                content: SingleChildScrollView(
                  child: Container(
                    height:200,
                    width: 200,
                    child: ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: actionNeeded.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Container(
                            padding: EdgeInsets.all(
                              20,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: Color.fromRGBO(120, 138, 244, .3),
                              ),
                            ),
                            child: Text(actionNeeded[index]),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      'Ok',
                      style: TextStyle(color: secondary),
                    ),
                    onPressed: () {
                      actionNeeded = [];
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        return showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Error"),
                content: Text(
                    "File to be uploaded doesn\'t contain required fields" +
                        " [ Roll Number, Phone Number, Name ]"),
                actions: [
                  TextButton(
                    child: Text(
                      'Ok',
                      style: TextStyle(color: secondary),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RelativeBuilder(
        builder: (context, screenHeight, screenWidth, sy, sx) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Upload Student Information',
            style: TextStyle(fontSize: sy(15) > sx(15) ? sy(15) : sx(15)),
          ),
          backgroundColor: primary,
        ),
        body: SingleChildScrollView(
          child: Container(
            color: background,
            padding: EdgeInsets.symmetric(
              vertical: sy(10),
              horizontal: sy(14),
            ),
            child: Column(
              children: [
                Container(
                  child: Text(
                    'Select the file to upload',
                    style: TextStyle(fontSize: sy(13) > sx(13) ? sy(13) : sx(13)),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: sy(10) > sx(10) ? sy(10) : sx(10))),
                FutureBuilder(
                    future: _getSpecificFileTypes(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                          return new Text('Waiting to start');
                        case ConnectionState.waiting:
                          return new Text('Loading...');
                        default:
                          if (snapshot.hasError) {
                            return new Text('Error: ${snapshot.error}');
                          } else {
                            return ListView.builder(
                              shrinkWrap: true,
                              primary: false,
                              itemCount: snapshot.data.length,
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
                                    child: Text(
                                        path.basename(snapshot.data[index].path)),
                                  ),
                                  onTap: () {
                                    Fluttertoast.showToast(msg: "Please wait while verifying this file");
                                    readXlsx(snapshot.data[index].path);
                                  }
                                );
                              },
                            );
                          }
                      }
                    }),
              ],
            ),
          ),
        ),
      );
    });
  }

  // get all files that match these extensions
  Future _getSpecificFileTypes() async {
    var status = await Permission.storage.request();
    var root = await getExternalStorageDirectory();

    var files = await FileManager(root: root)
        .filesTree(extensions: ["xlsx", "xlsm", "xlsb", "xltx", "xltm"]);
    return files;
  }
}
