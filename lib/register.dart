import 'package:finalyear/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _teacherCodeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController(); // Added for name
  String? _selectedUserType;
  String? _selectedDepartment;
  final addr = '127.0.0.1:5000';

  // Function to handle registration
  Future<void> _registerUser() async {
    // Validate passwords
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog("Passwords do not match!");
      return;
    }

    // Validate email format
    if (!_emailController.text.contains('@')) {
      _showErrorDialog("Invalid email address.");
      return;
    }

    // Ensure name is entered
    if (_nameController.text.isEmpty) {
      _showErrorDialog("Please enter your name.");
      return;
    }

    // Ensure user type is selected
    if (_selectedUserType == null) {
      _showErrorDialog("Please select a user type.");
      return;
    }

    // Ensure department or teacher code is provided based on user type
    if (_selectedUserType == "Student" && _selectedDepartment == null) {
      _showErrorDialog("Please select a department.");
      return;
    }
    if (_selectedUserType == "Teacher" && _teacherCodeController.text.isEmpty) {
      _showErrorDialog("Please provide the teacher code.");
      return;
    }

    final url = Uri.parse('http://$addr/register'); 
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': _nameController.text, // Include name
          'email': _emailController.text,
          'password': _passwordController.text,
          'user_type': _selectedUserType,
          'department': _selectedDepartment,
          'teacher_code': _teacherCodeController.text,
        }),
      );

      if (response.statusCode == 201) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => MyHome()));
      } else {
        _showErrorDialog("Registration failed: ${json.decode(response.body)['message']}");
      }
    } catch (error) {
      _showErrorDialog("An error occurred: $error");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: Text("Register", style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: height * .3,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(60),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.03, vertical: 20),
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name', // Name field
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedUserType,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedUserType = newValue;
                            _selectedDepartment = null;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Select User Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: <String>['Student', 'Teacher']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 10),
                      if (_selectedUserType == 'Student') ...[
                        DropdownButtonFormField<String>(
                          value: _selectedDepartment,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedDepartment = newValue;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Select Department',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          items: <String>[
                            'Bachelor of Science in Business Information Technology',
                            'Bachelor of Computer Engineering and IT'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 10),
                      ] else if (_selectedUserType == 'Teacher') ...[
                        TextField(
                          controller: _teacherCodeController,
                          decoration: InputDecoration(
                            labelText: 'Teacher Code',
                            prefixIcon: Icon(Icons.code),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _registerUser,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Register",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
