import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login.dart';
import 'package:fl_chart/fl_chart.dart'; // For graph rendering

class TeacherPage extends StatefulWidget {
  @override
  _TeacherPageState createState() => _TeacherPageState();
}

class _TeacherPageState extends State<TeacherPage> {
  final storage = FlutterSecureStorage();
  String teacherName = 'Loading...';
  String teacherEmail = 'Loading...';
  bool isLoading = true;
  String selectedPage = 'Teacher Details'; // Tracks the selected page
  List<Map<String, String>> studentList = [];
  List<FlSpot> attendanceGraphData = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    try {
      await _getTeacherDetails();
      await _getStudentList();
      await _getAttendanceData();
    } catch (e) {
      _showError('Failed to fetch data. Please try again later.');
    } finally {
      setState(() => isLoading = false);
    }
  }


  // Logout function to clear both SharedPreferences and FlutterSecureStorage
  Future<void> Logout(BuildContext context) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.clear();  // Clear saved preferences (including token)
    await storage.delete(key: 'access_token');  // Remove token from FlutterSecureStorage
    print('Logged out and cache cleared');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  Future<void> _getTeacherDetails() async {
    String? token = await storage.read(key: 'access_token');
    if (token != null) {
      final response = await _makeApiCall(
        endpoint: '/teacher/details',
        token: token,
      );
      if (response != null) {
        setState(() {
          teacherName = response['name'];
          teacherEmail = response['email'];
        });
      }
    }
  }

  // Future<void> _getStudentList() async {
  //   String? token = await storage.read(key: 'access_token');
  //   if (token != null) {
  //     final response = await _makeApiCall(
  //       endpoint: '/teacher/students',
  //       token: token,
  //     );
  //     if (response != null) {
  //       setState(() {
  //         studentList = List<Map<String, String>>.from(response['students']);
  //       });
  //       print("hello");
  //     }
  //   }
  // }

  void _showErrorMessage(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

Future<void> _getStudentList() async {
  try {
    String? token = await storage.read(key: 'access_token');
    if (token == null) {
      throw Exception("Access token not found. Please log in.");
    }

    final response = await _makeApiCall(
      endpoint: '/teacher/students',
      token: token,
    );

    if (response != null && response['students'] != null) {
      setState(() {
        studentList = List<Map<String, String>>.from(
          response['students'].map((student) => student.map((key, value) => MapEntry(key, value.toString())))
        );
      });
    } else {
      throw Exception("Invalid response from the server.");
    }
  } catch (error) {
    print("Error fetching student list: $error");
    _showErrorMessage("Failed to load student list. Please try again.");
  }
}

  Future<void> _getAttendanceData() async {
    String? token = await storage.read(key: 'access_token');
    if (token != null) {
      final response = await _makeApiCall(
        endpoint: '/teacher/attendance/data',
        token: token,
      );
      if (response != null) {
        setState(() {
          attendanceGraphData = List<FlSpot>.from(
            response['attendance'].map(
              (point) => FlSpot(
                point['day'].toDouble(),
                point['percentage'].toDouble(),
              ),
            ),
          );
        });
      }
    }
  }

  Future<Map<String, dynamic>?> _makeApiCall({
    required String endpoint,
    required String token,
  }) async {
    final url = Uri.parse('http://127.0.0.1:5000$endpoint');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        _redirectToLogin();
      } else {
        _showError('Error: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Failed to connect to the server.');
    }
    return null;
  }

  void _redirectToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Text('Teacher Dashboard', style: TextStyle(color: Colors.white)),
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
            title: Text('Log out'),
            onTap: () => Logout(context)
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherDetailsPage() => Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: $teacherName"),
            Text("Email: $teacherEmail"),
          ],
        ),
      );

  Widget _buildStudentListPage() => studentList.isEmpty
      ? Center(child: Text('No students found.'))
      : ListView.builder(
          itemCount: studentList.length,
          itemBuilder: (context, index) {
            var student = studentList[index];
            return ListTile(
              title: Text(student['name'] ?? 'Unknown'),
              subtitle: Text(student['email'] ?? 'No email'),
            );
          },
        );

  Widget _buildStudentGraphPage() => attendanceGraphData.isEmpty
      ? Center(child: Text('No attendance data available.'))
      : LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: attendanceGraphData,
                isCurved: true,
                colors: [Colors.blue],
              ),
            ],
          ),
        );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Teacher Dashboard")),
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
