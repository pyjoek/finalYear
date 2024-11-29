import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:finalyear/login.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

class StudentPage extends StatefulWidget {
  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final storage = FlutterSecureStorage();
  String studentName = '';
  String studentEmail = '';
  String department = '';
  List<FlSpot> attendanceData = [];  // To hold attendance data for the chart
  bool isAttendanceMarked = false;  // To track if attendance is already marked for today

  @override
  void initState() {
    super.initState();
    _getUserDetails();
    _getAttendanceData();  // Fetch attendance data when the page loads
  }

  // Logout function to clear both SharedPreferences and FlutterSecureStorage
  Future<void> Logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();  // Clear saved preferences (including token)
    await storage.delete(key: 'access_token');  // Remove token from FlutterSecureStorage
    print('Logged out and cache cleared');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  // Get user details from the API
  _getUserDetails() async {
    String? token = await storage.read(key: 'access_token');
    if (token != null) {
      var response = await http.get(
        Uri.parse('http://127.0.0.1:5000/protected'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          studentEmail = data['email'];
          studentName = data['name']; // Fetch name
          department = data['department'];
        });
      } else {
        print('Error: ${response.statusCode}');
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user details')),
        );
      }
    }
  }

  // Fetch hardcoded attendance data for now
  _getAttendanceData() async {
    // Hardcoded data for attendance (1 for Present, 0 for Absent)
    List<FlSpot> spots = [
      FlSpot(1, 1),  // Present in January
      FlSpot(2, 1),  // Present in February
      FlSpot(3, 0),  // Absent in March
      FlSpot(4, 1),  // Present in April
      FlSpot(5, 1),  // Present in May
      FlSpot(6, 0),  // Absent in June
      FlSpot(7, 1),  // Present in July
      FlSpot(8, 1),  // Present in August
      FlSpot(9, 0),  // Absent in September
      FlSpot(10, 1), // Present in October
    ];

    setState(() {
      attendanceData = spots;  // Set the attendance data for the chart
    });
  }

  // Mark attendance for today
  _markAttendance() async {
    String? token = await storage.read(key: 'access_token');
    if (token != null) {
      var response = await http.post(
        Uri.parse('http://127.0.0.1:5000/mark_attendance'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          isAttendanceMarked = true;  // Mark attendance as done only after successful response
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance marked for today!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark attendance')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Student Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => Logout(context),
          )
        ],
      ),
      body: SingleChildScrollView(  // Wrap the entire body with SingleChildScrollView
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Name: $studentName",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "Email: $studentEmail",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 5),
            Text(
              "Department: $department",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20),
            Text(
              "Attendance (January - Now)",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              height: height * 0.3,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: attendanceData.isNotEmpty ? attendanceData : [FlSpot(0, 0)],  // Use actual data or default
                      isCurved: true,
                      colors: [Colors.blue],
                      barWidth: 4,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: SideTitles(showTitles: true),
                    bottomTitles: SideTitles(showTitles: true),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Button to mark attendance
            ElevatedButton(
              onPressed: isAttendanceMarked ? null : _markAttendance,  // Disable button if attendance is already marked
              child: Text(isAttendanceMarked ? 'Attendance marked for today' : 'Mark Attendance'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
