import 'package:baraka/main.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _teacherCodeController = TextEditingController();
  String? _selectedUserType;
  String? _selectedDepartment;

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
                      // Email TextField
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
                      // Password TextField
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
                      // Confirm Password TextField
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
                      // User Type Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedUserType,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedUserType = newValue;
                            _selectedDepartment = null; // Reset department selection when user type changes
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
                      
                      // Conditional Fields based on User Type
                      if (_selectedUserType == 'Student') ...[
                        // Department Dropdown for Students
                        DropdownButtonFormField<String>(
                          value: _selectedDepartment,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedDepartment = newValue;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Select Department',
                            contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 6), // Further reduced padding
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
                              child: Text(
                                value,
                                style: TextStyle(fontSize: 14), // Font size remains the same
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 10),
                      ] else if (_selectedUserType == 'Teacher') ...[
                        // Teacher Code TextField
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
                      // Register Button
                      ElevatedButton(
                        onPressed: () {
                          // Register button pressed
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: InkWell(
                          onTap: () => {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => MyHome()))
                          },
                          child: Text(
                            "Register",
                            style: TextStyle(fontSize: 18),
                          ),
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
