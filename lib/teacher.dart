import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart'; // To scan the QR code
import 'login.dart';
import 'package:flutter/services.dart'; // For clipboard support

class TeacherPage extends StatefulWidget {
  @override
  _TeacherPageState createState() => _TeacherPageState();
}

class _TeacherPageState extends State<TeacherPage> {
  final storage = FlutterSecureStorage();
  String teacherName = '';
  String? attendanceQRCodeUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getTeacherDetails();
    _generateAttendanceQRCode();
  }

  // Fetch teacher details
  Future<void> _getTeacherDetails() async {
    String? token = await storage.read(key: 'access_token');
    if (token != null) {
      var response = await http.get(
        Uri.parse('http://127.0.0.1:5000/teacher/details'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          teacherName = data['name'];
        });
      } else {
        print('Failed to fetch teacher details: ${response.body}');
      }
    }
  }

  // Generate QR code for attendance
  Future<void> _generateAttendanceQRCode() async {
    String? token = await storage.read(key: 'access_token');
    if (token != null) {
      var response = await http.get(
        Uri.parse('http://127.0.0.1:5000/teacher/attendance/qrcode'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          attendanceQRCodeUrl = response.body; // The image URL or base64 data
          isLoading = false;
        });
      } else {
        print('Failed to generate QR code: ${response.body}');
      }
    }
  }

  // Scan QR code using flutter_barcode_scanner
  Future<void> _scanQR() async {
    String scanResult = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666', 'Cancel', true, ScanMode.QR);
    
    if (scanResult != '-1') {
      // Send the scanned QR code to backend for attendance marking
      await _submitAttendance(scanResult);
    }
  }

  // Submit attendance based on scanned QR code
  Future<void> _submitAttendance(String attendanceToken) async {
    String? token = await storage.read(key: 'access_token');
    String studentId = '12345';  // Get student ID from storage or API

    var response = await http.post(
      Uri.parse('http://127.0.0.1:5000/student/attendance'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({
        'attendance_token': attendanceToken,
        'student_id': studentId,
      }),
    );

    if (response.statusCode == 200) {
      print('Attendance successfully marked!');
      // Optionally, show a confirmation message
    } else {
      print('Failed to mark attendance: ${response.body}');
    }
  }

  // Logout
  Future<void> _logout() async {
    await storage.delete(key: 'access_token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Teacher Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome, $teacherName",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Generate Attendance QR Code",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: attendanceQRCodeUrl == null
                        ? CircularProgressIndicator()
                        : Image.memory(
                            base64Decode(attendanceQRCodeUrl!),
                            width: 200,
                            height: 200,
                          ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _scanQR,
                    child: Text("Scan QR Code"),
                  ),
                ],
              ),
            ),
    );
  }
}
