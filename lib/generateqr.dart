import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
        title: Text('Generate QR Code for Attendance'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Remove the QrImage from the Column
        Container(  // Wrap QrImage in a Container or any appropriate widget
        child:  QrImageView(
              data: qrCodeData,
              size: 200.0,
            ),),
            SizedBox(height: 20.0),
            Text(
              'QR Code ID: $qrCodeId',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 20.0),
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

            Row(
              children: [
                Column(
                  children: [
                    Text("ATTENDANCE")

                  ],),
                  Column(children: [
                  ListView.builder(
                  itemCount: attendanceData.length,
                    itemBuilder: (context, index) {
                      final date = attendanceData[index]['date'];
                      final email = attendanceData[index]['email'];

                      return ListTile(
                        title: Text('Date: $date'),
                        subtitle: Text('Email: $email'),
                      );
                    },
                  ),

                  ],)

              ],
            )
          ],
        ),
      ),
    );
  }
  Future<List<Map<String, dynamic>>> getAttendanceData() async {
    final QuerySnapshot<Map<String, dynamic>> attendanceSnapshot =
    await FirebaseFirestore.instance.collection('attendance').get();

    final List<Map<String, dynamic>> attendanceList = [];

    attendanceSnapshot.docs.forEach((DocumentSnapshot<Map<String, dynamic>> doc) {
      final dataA = doc.data();
      attendanceList.add(dataA!);
    });

    return attendanceList;
  }
}





void main() {
  runApp(MaterialApp(
    title: 'Attendance QR Code Generator',
    home: AttendanceQRCodeScreen(),
  ));
}
