import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:finalyear/login.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentPage extends StatefulWidget {
  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final storage = FlutterSecureStorage();
  String studentName = '';
  String studentEmail = '';
  String department = '';
  bool isAttendanceMarked = false;  // To track if attendance is already marked for today
  List<Map<String, dynamic>> attendanceHistory = []; // To hold attendance data for display

  @override
  void initState() {
    super.initState();
    _getUserDetails();
    _getAttendanceHistory();  // Fetch attendance history when the page loads
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

  // Fetch attendance history from the API
  _getAttendanceHistory() async {
    String? token = await storage.read(key: 'access_token');
    if (token != null) {
      var response = await http.get(
        Uri.parse('http://127.0.0.1:5000/attendance_history'), // API endpoint for attendance history
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body)['attendance'];
        print(data);

        // Check if the response is a List and handle it accordingly
        if (data is List) {
          setState(() {
            attendanceHistory = List<Map<String, dynamic>>.from(data);
          });
        } else {
          // Handle unexpected response format
          print('Error: Expected a List, but got ${data.runtimeType}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load attendance history')),
          );
        }
      } else {
        print('Error: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load attendance history')),
        );
      }
    }
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Attendance History',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            // Attendance table inside the drawer
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DataTable(
                columns: const <DataColumn>[
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Status')),
                ],
                rows: attendanceHistory
                    .map<DataRow>((attendance) => DataRow(
                          cells: <DataCell>[
                            DataCell(Text(attendance['date'] ?? 'N/A')),
                            DataCell(Text(attendance['status'] == 1 ? 'Present' : 'Absent')),
                          ],
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: isAttendanceMarked ? null : _markAttendance, // Disable if attendance is marked
              child: Text(
                isAttendanceMarked ? 'Attendance marked for today' : 'Mark Attendance',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
