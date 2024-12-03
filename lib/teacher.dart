import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login.dart';
import 'package:fl_chart/fl_chart.dart';  // For Graph

class TeacherPage extends StatefulWidget {
  @override
  _TeacherPageState createState() => _TeacherPageState();
}

class _TeacherPageState extends State<TeacherPage> {
  final storage = FlutterSecureStorage();
  String teacherName = '';
  String teacherEmail = '';
  bool isLoading = true;
  String selectedPage = 'Teacher Details';  // Track the selected page
  List<Map<String, String>> studentList = [];  // Store student details for listing
  List<FlSpot> attendanceGraphData = []; // Dynamic graph data

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Fetch all data
  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    await _getTeacherDetails();
    await _getStudentList();
    await _getAttendanceData();
    setState(() => isLoading = false);
  }

  // Fetch teacher details
  Future<void> _getTeacherDetails() async {
    try {
      String? token = await storage.read(key: 'access_token');
      if (token != null) {
        var response = await http.get(
          Uri.parse('http://127.0.0.1:5000/teacher/details'),
          headers: {'Authorization': 'Bearer $token'},
        );
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          print(data);
          setState(() {
            teacherName = data['name'];
            teacherEmail = data['email'];
            // print("for teacher `$teacherEmail`, `$teacherName`");
          });
        } else if (response.statusCode == 401) {
          _redirectToLogin();
        } else {
          _showError('Failed to fetch teacher details.');
        }
      }
    } catch (e) {
      _showError('An error occurred while fetching teacher details.');
    }
  }

  // Fetch student list
  Future<void> _getStudentList() async {
    try {
      String? token = await storage.read(key: 'access_token');
      if (token != null) {
        var response = await http.get(
          Uri.parse('http://127.0.0.1:5000/teacher/students'),
          headers: {'Authorization': 'Bearer $token'},
        );
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          setState(() {
            studentList = List<Map<String, String>>.from(data['students']);
          });
        } else if (response.statusCode == 401) {
          _redirectToLogin();
        } else {
          _showError('Failed to fetch student list.');
        }
      }
    } catch (e) {
      _showError('An error occurred while fetching student list.');
    }
  }

  // Fetch attendance data for the graph
  Future<void> _getAttendanceData() async {
    try {
      String? token = await storage.read(key: 'access_token');
      if (token != null) {
        var response = await http.get(
          Uri.parse('http://127.0.0.1:5000/teacher/attendance/data'),
          headers: {'Authorization': 'Bearer $token'},
        );
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          setState(() {
            attendanceGraphData = List<FlSpot>.from(
              data['attendance'].map((point) => FlSpot(
                    point['day'].toDouble(),
                    point['percentage'].toDouble(),
                  )),
            );
          });
        } else if (response.statusCode == 401) {
          _redirectToLogin();
        } else {
          _showError('Failed to fetch attendance data.');
        }
      }
    } catch (e) {
      _showError('An error occurred while fetching attendance data.');
    }
  }

  // Redirect to login if unauthorized
  void _redirectToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  // Show error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Logout with confirmation
  Future<void> _logout() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Logout')),
        ],
      ),
    );
    if (confirm == true) {
      await storage.delete(key: 'access_token');
      _redirectToLogin();
    }
  }

  // Build the drawer
  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('Teacher Dashboard', style: TextStyle(fontSize: 24, color: Colors.white)),
            decoration: BoxDecoration(color: Colors.black),
          ),
          ListTile(
            title: Text('Teacher Details'),
            onTap: () => setState(() => selectedPage = 'Teacher Details'),
          ),
          ListTile(
            title: Text('Student List'),
            onTap: () => setState(() => selectedPage = 'Student List'),
          ),
          ListTile(
            title: Text('Student Graph'),
            onTap: () => setState(() => selectedPage = 'Student Graph'),
          ),
          ListTile(
            title: Text('Logout'),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  // Build pages
  Widget _buildTeacherDetailsPage() => Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Teacher: $teacherName", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Email: $teacherEmail", style: TextStyle(fontSize: 18)),
          ],
        ),
      );

  Widget _buildStudentListPage() => ListView.builder(
        itemCount: studentList.length,
        itemBuilder: (context, index) {
          var student = studentList[index];
          return ListTile(
            title: Text(student['name'] ?? 'Unknown'),
            subtitle: Text(student['email'] ?? 'No email'),
          );
        },
      );

  Widget _buildStudentGraphPage() => Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Student Attendance Graph', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(
              height: 300,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: attendanceGraphData,
                      isCurved: true,
                      colors: [Colors.blue],
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: SideTitles(showTitles: true),
                    bottomTitles: SideTitles(showTitles: true),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Teacher Dashboard"),
        centerTitle: true,
      ),
      drawer: _buildDrawer(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : selectedPage == 'Teacher Details'
              ? _buildTeacherDetailsPage()
              : selectedPage == 'Student List'
                  ? _buildStudentListPage()
                  : _buildStudentGraphPage(),
    );
  }
}
