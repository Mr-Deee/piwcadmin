import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';


class AttendanceQRCodeScreen extends StatefulWidget {
  @override
  _AttendanceQRCodeScreenState createState() => _AttendanceQRCodeScreenState();
}

class _AttendanceQRCodeScreenState extends State<AttendanceQRCodeScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String qrCodeData = '';
  String qrCodeId = '';


  List<Map<String, dynamic>> attendanceData = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAttendanceData();
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    final data = await getAttendanceData();
    setState(() {
      attendanceData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    // Format the date as a string (e.g., "2023-09-21")
    String formattedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('PIWC ADMIN'),
        actions: [    IconButton(
          onPressed: () {


            showDialog<void>(
              context: context,
              barrierDismissible: false, // user must tap button!
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Sign Out'),
                  backgroundColor: Colors.white,
                  content: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Text('Are you certain you want to Sign Out?'),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text(
                        'Yes',
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () {
                        print('yes');
                        FirebaseAuth.instance.signOut();
                        Navigator.pushNamedAndRemoveUntil(
                            context, "/login", (route) => false);
                        // Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          icon: const Icon(
            Icons.logout,
            color: Colors.black,
          ),
        ),],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Remove the QrImage from the Column
              Container(  // Wrap QrImage in a Container or any appropriate widget
              child:  QrImageView(
                    data: qrCodeData,
                    size: 100.0,
                  ),),
                  SizedBox(height: 10.0),
                  Text(
                    'QR Code ID: $qrCodeId',

                    style: TextStyle(fontSize: 12.0),
                  ),
                  SizedBox(height: 10.0),
                  ElevatedButton(
                    onPressed: () {
                      // Generate a random QR Code ID (you can use any logic to generate IDs)
                      String newQrCodeId =
                      DateTime.now().millisecondsSinceEpoch.toString();

                      // Generate a new QR code data (you can use any logic for the data)
                      String newQrCodeData = 'Attendance for $newQrCodeId';

                      // Update the QR code ID and data in the state
                      setState(() {

                        qrCodeId = newQrCodeId;
                        qrCodeData = newQrCodeData;
                      });

                      // Write the QR code data to Firebase with the assigned ID
                      firestore.collection('GenearatedQr').doc(qrCodeId).set({
                        "Date":formattedDate,
                        'data': qrCodeData,
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                    },
                    child: Text('Generate QR Code'),
                  ),



                ],
              ),

                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text("ATTENDANCE",style: TextStyle(fontWeight: FontWeight.bold),),
                        ElevatedButton(
                                onPressed: () {
                                  exportToExcel(); // Call the export function when the button is pressed
                                },
                                child: Column(
                                  children: [
                                    Icon(Icons.import_export_rounded),
                                    Text('Export to Excel'),
                                  ],
                                ),
                              ),
                            ],



                      ),
                    ),
          Container(
            height: MediaQuery.of(context)
                .size
                .height *
                0.39,
            child:
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('Attendance').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  List<DocumentSnapshot> attendanceData = snapshot.data!.docs;

                  // Filter data by current date
                  attendanceData = attendanceData.where((document) {
                    final date = document['DateChecked'];
                    // Replace 'currentDate' with the actual way you get the current date in your app
                    final currentDate = DateTime.now().toLocal().toString().split(' ')[0];
                    return date == currentDate;
                  }).toList();

                  return ListView.builder(
                    itemCount: attendanceData.length,
                    itemBuilder: (context, index) {
                      final date = attendanceData[index]['DateChecked'];
                      final email = attendanceData[index]['email'];
                      final phone = attendanceData[index]['phone'];
                      final occupation = attendanceData[index]['Occupation'];

                      return ListTile(
                        title: Text('Date: $date'),
                        subtitle: Column(
                          children: [
                            Text('Email: $email' ?? ""),
                            Text('Phone: $phone'),
                            Text('Occupation: $occupation' ?? ""),
                            Divider(height: 2.0, color: Colors.black),
                          ],
                        ),

                      );
                    },
                  );
                }
              },
            )

          ),

            ],
          ),
        ),
      ),
    );
  }


  Future<void> exportToExcel() async {
    final excelFile = Excel.createExcel();
    final sheet = excelFile['Sheet1']; // Change the sheet name as needed

    // Add headers to the Excel sheet
    sheet.cell(CellIndex.indexByString("A1")).value = 'Date';
    sheet.cell(CellIndex.indexByString("B1")).value = 'Email';

    // Add attendance data to the Excel sheet
    for (int i = 0; i < attendanceData.length; i++) {
      final date = attendanceData[i]['DateChecked'];
      final email = attendanceData[i]['email'];
      sheet.cell(CellIndex.indexByString("A${i + 2}")).value = date;
      sheet.cell(CellIndex.indexByString("B${i + 2}")).value = email;
    }

    // Get the documents directory
    final directory = await getApplicationDocumentsDirectory();

    // Define the file path
    final filePath = '${directory.path}/attendance_excel.xlsx';

    // Save the Excel file to the documents directory
    final file = await excelFile.encode();

    File(filePath).writeAsBytesSync(file!);
    displayToast("Your File is this directory: $filePath", context);

    // You can now share or open the file using a file picker or other methods
    // For example, you can use the 'open_file' package to open the file.
  }


  Future<List<Map<String, dynamic>>> getAttendanceData() async {
    final DateTime currentDate = DateTime.now();
    final DateTime previousDate = currentDate.subtract(Duration(days: 1));
    String formattedDate =
        "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";
    String formattedPreviousDate =
        "${previousDate.year}-${previousDate.month.toString().padLeft(2, '0')}-${previousDate.day.toString().padLeft(2, '0')}";

    final QuerySnapshot<Map<String, dynamic>> attendanceSnapshot =
    await FirebaseFirestore.instance
        .collection('Attendance')
        .where('DateChecked',
        isGreaterThanOrEqualTo: formattedPreviousDate,
        isLessThanOrEqualTo: formattedDate)
        .get();

    List<Map<String, dynamic>> attendanceList = [];

    attendanceSnapshot.docs.forEach((DocumentSnapshot<Map<String, dynamic>> doc) {
      final dataA = doc.data();
      attendanceList.add(dataA!);
    });

    // Sort the attendanceList in descending order by 'DateChecked'
    attendanceList.sort((a, b) {
      DateTime dateA = DateTime.parse(a['DateChecked']);
      DateTime dateB = DateTime.parse(b['DateChecked']);
      return dateB.compareTo(dateA); // Compare in descending order
    });

    return attendanceList;
  }



  displayToast(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);

// user created
  }
}





void main() {
  runApp(MaterialApp(
    title: 'Attendance QR Code Generator',
    home: AttendanceQRCodeScreen(),
  ));
}
