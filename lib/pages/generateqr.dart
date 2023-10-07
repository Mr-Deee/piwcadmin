import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:excel/excel.dart';


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
        title: Text('PIWC Attendance'),
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


                  ElevatedButton(
                    onPressed: () {
                      exportToExcel(); // Call the export function when the button is pressed
                    },
                    child: Text('Export to Excel'),
                  ),
                ],
              ),

                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        children: [
                          Text("ATTENDANCE")

                        ],

                      ),
                    ),
                      Column(
              children: [
                      Container(
                        height: 500,
                        child: ListView.builder(
                        itemCount: attendanceData.length,
                          itemBuilder: (context, index) {
                            final date = attendanceData[index]['DateChecked'];
                            final email = attendanceData[index]['email'];

                            return ListTile(
                              title: Text('Date: $date'),
                              subtitle: Text('Email: $email'),
                            );
                          },
                        ),
                      ),




                      ]




             )
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

    // Save the Excel file to a temporary directory
    final file = await excelFile.encode();

    // You can save the file or share it using a file picker or other methods
    // For example, you can use the path_provider package to get the documents directory and save the file there.
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

//   Future<List<Map<String, dynamic>>> getAttendanceData() async {
//     final DateTime currentDate = DateTime.now();
//     final DateTime previousDate = currentDate.subtract(Duration(days: 1));
// print(currentDate);
//     final QuerySnapshot<Map<String, dynamic>> attendanceSnapshot =
//     await FirebaseFirestore.instance.collection('Attendance')
//         .where('DateChecked', isGreaterThanOrEqualTo: previousDate, isLessThanOrEqualTo: currentDate)
//         .get();
//
//
//     final List<Map<String, dynamic>> attendanceList = [];
//
//     attendanceSnapshot.docs.forEach((DocumentSnapshot<Map<String, dynamic>> doc) {
//       final dataA = doc.data();
//       attendanceList.add(dataA!);
//     });
//
//     return attendanceList;
//   }
}





void main() {
  runApp(MaterialApp(
    title: 'Attendance QR Code Generator',
    home: AttendanceQRCodeScreen(),
  ));
}
