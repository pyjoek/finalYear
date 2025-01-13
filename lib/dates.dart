import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() => runApp(Dates());
class Dates extends StatefulWidget {
  const Dates({super.key});

  @override
  State<Dates> createState() => _DatesState();
}

class _DatesState extends State<Dates> {
  final storage = FlutterSecureStorage();
  final String addr = "127.0.0.1:5000";
  List<Map<String, dynamic>> attendanceHistory = [];

  @override 
  void initState() {
    super.initState();
    _getAttendanceHistory();
  }

  _getAttendanceHistory() async {
    // String? token = await storage.read(key: 'access_token');
    var response = await http.get(
      Uri.parse('http://$addr/attendanceHistory'), 
    );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body)['attendance'];
        print(data);

        // Check if the response is a List and handle it accordingly
        if (data is List) {
          setState(() {
            attendanceHistory = List<Map<String, dynamic>>.from(data);
          });
          print(attendanceHistory);
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
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: InkWell(
            onTap: () => _getAttendanceHistory(),
            child: Text("CLick kme"),
          ),
        ),
      ),
    );
  }
}