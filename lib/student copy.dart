import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For encoding/decoding JSON
import 'login.dart';

class StudentPage extends StatefulWidget {
  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final String studentName = "John Doe";
  final String department = "Computer Science";

  // Logout function
  Future<void> _logout() async {
    // Get the stored token
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('user_token');

    if (token != null) {
      // Send request to logout endpoint
      final response = await http.post(
        Uri.parse('http://yourserver.com/logout'), // Replace with your server's logout URL
        headers: {
          'Authorization': 'Bearer $token', // Pass the token in the header
        },
      );

      if (response.statusCode == 200) {
        // If logout is successful, clear token and navigate to login
        await prefs.remove('user_token');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      } else {
        // Handle failure (you can show an error message here)
        print("Logout failed: ${response.body}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout, // Call logout function
          ),
        ],
      ),
      body: Center(
        child: Text("Welcome, $studentName!"),
      ),
    );
  }
}
