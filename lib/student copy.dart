// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'login.dart'; // Your login page
// import 'package:fl_chart/fl_chart.dart';

// class StudentPage extends StatefulWidget {
//   @override
//   _StudentPageState createState() => _StudentPageState();
// }

// class _StudentPageState extends State<StudentPage> {
//   final storage = FlutterSecureStorage();
//   String studentName = '';
//   String department = '';

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
//           print(studentName);
//           department = data['department'] ?? "Not available";
//         });
//       } else {
//         print('Error: ${response.statusCode}');
//         print(response.body);
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
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Login API interaction
// Future<void> login(String email, String password, BuildContext context) async {
//   var response = await http.post(
//     Uri.parse('http://localhost:5000/login'),
//     headers: {'Content-Type': 'application/json'},
//     body: jsonEncode({'email': email, 'password': password}),
//   );

//   if (response.statusCode == 200) {
//     var data = jsonDecode(response.body);
//     String token = data['access_token'];

//     // Store token securely
//     final storage = FlutterSecureStorage();
//     await storage.write(key: 'access_token', value: token);

//     // Navigate to the StudentPage
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => StudentPage()),
//     );
//   } else {
//     print('Login failed: ${response.body}');
//   }
// }
