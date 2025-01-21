import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:finalyear/login.dart';
import 'dart:convert';

class TeacherPage extends StatefulWidget {
  @override
  _TeacherPageState createState() => _TeacherPageState();
}

class _TeacherPageState extends State<TeacherPage> {
  final storage = FlutterSecureStorage();
  List<dynamic> students = [];
  List<String> attendanceDates = [];
  bool isLoading = true;
  String currentPage = "Students"; // To track the current page

  @override
  void initState() {
    super.initState();
    _loadStudentList();
    _loadAttendanceDates();
  }

  // Load the list of students from the backend
  Future<void> _loadStudentList() async {
    final token = await storage.read(key: 'access_token');
    final response = await http.get(
      Uri.parse('http://localhost:5000/teacher/students'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['students'];
      setState(() {
        students = data;
        isLoading = false;
      });
    } else {
      // Handle the error appropriately
      setState(() {
        isLoading = false;
      });
    }
  }

  // Load the list of attendance dates from the backend
  Future<void> _loadAttendanceDates() async {
    final token = await storage.read(key: 'access_token');
    final response = await http.get(
      Uri.parse('http://localhost:5000/attendance_dates'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<String> dates = List<String>.from(json.decode(response.body)['dates']);
      setState(() {
        attendanceDates = dates;
      });
    }
  }

  // Show student details for a selected attendance date
  Future<void> _showAttendanceDetails(String date) async {
    final token = await storage.read(key: 'access_token');
    final response = await http.get(
      Uri.parse('http://localhost:5000/attendance_details?date=$date'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['students'];
      // Show the student list who attended on that day
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Attendance for $date'),
            content: Column(
              children: data
                  .map<Widget>((student) => Text('${student['name']} (${student['email']})'))
                  .toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  // Update the current page based on Drawer selection
  void _updatePage(String page) {
    setState(() {
      currentPage = page;
    });
  }

  // Widget to display the student list
  Widget _buildStudentList() {
    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    Text((students[index]['name']).toUpperCase(), 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                    Text(students[index]['email']),
                  ],
                ),
              ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 3,
                      spreadRadius: 0,
                      offset: Offset(0, 3)
                    )
                  ]
                )
            ),
        SizedBox(height: 10,)
          ],
        );
      },
    );
  }

  // Widget to display attendance dates
  Widget _buildAttendanceDates() {
    return ListView.builder(
      itemCount: attendanceDates.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(attendanceDates[index]),
          trailing: IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              _showAttendanceDetails(attendanceDates[index]);
            },
          ),
        );
      },
    );
  }

  // Logout function
  Future<void> _logout() async {
    await storage.delete(key: 'access_token');  // Delete token to log out
    Navigator.pushReplacementNamed(context, '/login');  // Redirect to login screen
  }

  Future<void> Logout(BuildContext context) async {
    await storage.delete(key: 'access_token');  // Remove token from FlutterSecureStorage
    print('Logged out and cache cleared');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  // Fetch teacher details (name and email)
  Future<Map<String, String>> _fetchTeacherDetails() async {
    final token = await storage.read(key: 'access_token');
    final response = await http.get(
      Uri.parse('http://localhost:5000/teacher/details'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'name': data['name'],
        'email': data['email'],
      };
    } else {
      return {'name': 'Unknown', 'email': 'Unknown'};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Dashboard'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: FutureBuilder<Map<String, String>>(
                future: _fetchTeacherDetails(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error loading teacher details');
                  } else {
                    final teacher = snapshot.data;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(children: [
                            Text(
                              (teacher?['name'] ?? 'Teacher Name').toUpperCase(),
                              style: TextStyle(color: Colors.white, fontSize: 26
                              , fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text(
                              teacher?['email'] ?? 'teacher@example.com',
                              style: TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ],),
                          
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
            ListTile(
              title: Text('Students'),
              onTap: () {
                _updatePage("Students");
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Attendance'),
              onTap: () {
                _updatePage("Attendance");
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () {
                Logout(context);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                    child: currentPage == "Students"
                        ? _buildStudentList()
                        : _buildAttendanceDates(),
                  ),
          ],
        ),
      ),
    );
  }
}
