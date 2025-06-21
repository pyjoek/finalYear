import 'package:finalyear/forgotpassword.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:finalyear/student.dart';
import 'package:finalyear/teacher.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final LocalAuthentication auth = LocalAuthentication();
  late double height, width;

  final addr = '127.0.0.1:5000';
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> login() async {
    try {
      final response = await http.post(
        Uri.parse('http://$addr/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String token = data['access_token'];
        String userType = data['user_type'];

        await storage.write(key: 'access_token', value: token);
        await storage.write(key: 'user_type', value: userType);

        _navigateToUserPage(userType);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid credentials')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> biometricLogin() async {
    bool canAuthenticate = await auth.canCheckBiometrics || await auth.isDeviceSupported();
    if (!canAuthenticate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Biometric authentication not available")),
      );
      return;
    }

    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Scan your biometrics to login',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication failed: $e')),
      );
      return;
    }

    if (authenticated) {
      String? token = await storage.read(key: 'access_token');
      String? userType = await storage.read(key: 'user_type');

      if (token != null && userType != null) {
        _navigateToUserPage(userType);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No previous login found')),
        );
      }
    }
  }

  void _navigateToUserPage(String userType) {
    if (userType == 'Student') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StudentPage()),
      );
    } else if (userType == 'Teacher') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TeacherPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: Text("Login", style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: height * .4,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(60),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Positioned(
              left: width * 0.1,
              right: width * 0.1,
              bottom: height * 0.3,
              child: Container(
                padding: EdgeInsets.all(16),
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
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text("Login", style: TextStyle(fontSize: 18)),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Forgot())),
                     child: Text("Forgot Password")),
                    SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: biometricLogin,
                      icon: Icon(Icons.fingerprint, size: 20),
                      label: Text("Login with Biometrics"),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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
    );
  }
}
