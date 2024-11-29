// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'login.dart'; // Your login page
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart'; // Import QR scanner package

// class StudentPage extends StatefulWidget {
//   @override
//   _StudentPageState createState() => _StudentPageState();
// }

// class _StudentPageState extends State<StudentPage> {
//   final storage = FlutterSecureStorage();
//   String studentName = '';
//   String department = '';
//   String qrCode = ''; // To hold the scanned QR code
//   bool isAttendanceSubmitted = false;

//   @override
//   void initState() {
//     super.initState();
//     _getUserDetails();
//   }

//   // Get user details from the API
//   _getUserDetails() async {
//     String? token = await storage.read(key: 'access_token');
//     if (token != null) {
//       var response = await http.get(
//         Uri.parse('http://localhost:5000/protected'),
//         headers: {'Authorization': 'Bearer $token'},
//       );

//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//         setState(() {
//           studentName = data['email'];
//           department = data['department'] ?? "Not available";
//         });
//       } else {
//         print('Error: ${response.statusCode}');
//         print(response.body);
//       }
//     }
//   }

//   // Submit attendance based on the QR code
//   _submitAttendance() async {
//     String? token = await storage.read(key: 'access_token');
//     if (token != null && qrCode.isNotEmpty) {
//       var response = await http.post(
//         Uri.parse('http://localhost:5000/student/attendance'),
//         headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
//         body: jsonEncode({'attendance_token': qrCode, 'student_id': studentName}), // Pass student ID and the scanned QR code
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           isAttendanceSubmitted = true;
//         });
//         print('Attendance submitted successfully');
//       } else {
//         print('Failed to submit attendance');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     double height = MediaQuery.of(context).size.height;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         title: Text("Student Dashboard"),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.logout),
//             onPressed: () async {
//               await storage.delete(key: 'access_token');
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (context) => Login()),
//               );
//             },
//           )
//         ],
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Text(
//               "Name: $studentName",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 5),
//             Text(
//               "Department: $department",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
//             ),
//             SizedBox(height: 20),
//             // Attendance Graph
//             Text(
//               "Attendance (January - Now)",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             Container(
//               height: height * 0.3,
//               child: LineChart(
//                 LineChartData(
//                   lineBarsData: [
//                     LineChartBarData(
//                       spots: [
//                         FlSpot(0, 3),  // Example data
//                         FlSpot(1, 4),
//                         FlSpot(2, 3),
//                         FlSpot(3, 5),
//                       ],
//                       isCurved: true,
//                       colors: [Colors.blue],
//                       barWidth: 4,
//                       belowBarData: BarAreaData(show: false),
//                     ),
//                   ],
//                   titlesData: FlTitlesData(
//                     leftTitles: SideTitles(showTitles: true),
//                     bottomTitles: SideTitles(showTitles: true),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 20),
//             // QR Code Scanner for Attendance
//             Text(
//               "Scan QR Code to Mark Attendance",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: () async {
//                 // Call a QR scanner here
//                 String scannedCode = await Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => QrScannerPage()),
//                 );

//                 if (scannedCode != null && scannedCode.isNotEmpty) {
//                   setState(() {
//                     qrCode = scannedCode;  // Set scanned QR code
//                     isAttendanceSubmitted = false;
//                   });
//                 }
//               },
//               child: Text('Scan QR Code'),
//             ),
//             SizedBox(height: 20),
//             // Submit Attendance Button
//             if (qrCode.isNotEmpty && !isAttendanceSubmitted) 
//               ElevatedButton(
//                 onPressed: _submitAttendance,
//                 child: Text('Submit Attendance'),
//               ),
//             if (isAttendanceSubmitted)
//               Text(
//                 'Attendance Submitted Successfully!',
//                 style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // QR Code Scanner page
// class QrScannerPage extends StatefulWidget {
//   @override
//   _QrScannerPageState createState() => _QrScannerPageState();
// }

// class _QrScannerPageState extends State<QrScannerPage> {
//   String scannedCode = '';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("QR Scanner")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               scannedCode.isEmpty ? 'Scan a QR Code' : 'Scanned Code: $scannedCode',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context, scannedCode);  // Return scanned code to StudentPage
//               },
//               child: Text('Return to Dashboard'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
