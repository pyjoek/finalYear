// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'student.dart'; // Make sure this file exists
// import 'teacher.dart'; // Make sure this file exists
// import 'package:local_auth/local_auth.dart';

// class Login extends StatefulWidget {
//   @override
//   _LoginState createState() => _LoginState();
// }

// class _LoginState extends State<Login> {
//   late double height, width;
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final LocalAuthentication auth = LocalAuthentication();

//   Future<void> login() async {
//     try {
//       final response = await http.post(
//         Uri.parse('http://127.0.0.1:5000/login'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'email': _emailController.text,
//           'password': _passwordController.text,
//         }),
//       );

//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//         String token = data['access_token'];
//         String userType = data['user_type'];

//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         prefs.setString('token', token);

//         if (userType == 'Student') {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => StudentPage()),
//           );
//         } else if (userType == 'Teacher') {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => TeacherPage()),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Unknown user type')),
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Invalid credentials')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }

//   Future<void> _authenticateWithBiometrics() async {
//     try {
//       bool isAuthenticated = await auth.authenticate(
//         localizedReason: 'Authenticate to login',
//         options: const AuthenticationOptions(
//           biometricOnly: true,
//           stickyAuth: true,
//         ),
//       );

//       if (isAuthenticated) {
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         String? token = prefs.getString('token');

//         if (token != null) {
//           // Navigate based on user type or saved data
//           // Assuming user type is also saved in preferences
//           String? userType = prefs.getString('user_type');

//           if (userType == 'Student') {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => StudentPage()),
//             );
//           } else if (userType == 'Teacher') {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => TeacherPage()),
//             );
//           } else {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Unknown user type')),
//             );
//           }
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('No saved session found')),
//           );
//         }
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Biometric authentication failed: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     height = MediaQuery.of(context).size.height;
//     width = MediaQuery.of(context).size.width;

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.black,
//           leading: InkWell(
//             onTap: () => Navigator.pop(context),
//             child: Icon(Icons.arrow_back, color: Colors.white),
//           ),
//           title: Text("Login", style: TextStyle(color: Colors.white)),
//           centerTitle: true,
//         ),
//         body: Stack(
//           children: [
//             Column(
//               children: [
//                 Container(
//                   height: height * .4,
//                   decoration: BoxDecoration(
//                     color: Colors.black,
//                     borderRadius: BorderRadius.only(
//                       bottomRight: Radius.circular(60),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: Container(
//                     color: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//             Positioned(
//               left: width * 0.1,
//               right: width * 0.1,
//               bottom: height * 0.2,
//               child: Container(
//                 padding: EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black26,
//                       blurRadius: 10,
//                       offset: Offset(0, 5),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     TextField(
//                       controller: _emailController,
//                       decoration: InputDecoration(
//                         labelText: 'Email',
//                         prefixIcon: Icon(Icons.email),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     TextField(
//                       controller: _passwordController,
//                       obscureText: true,
//                       decoration: InputDecoration(
//                         labelText: 'Password',
//                         prefixIcon: Icon(Icons.lock),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: login,
//                       style: ElevatedButton.styleFrom(
//                         padding: EdgeInsets.symmetric(vertical: 14.0),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       child: Text(
//                         "Login",
//                         style: TextStyle(fontSize: 18),
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     ElevatedButton.icon(
//                       onPressed: _authenticateWithBiometrics,
//                       icon: Icon(Icons.fingerprint),
//                       label: Text("Login with Biometrics"),
//                       style: ElevatedButton.styleFrom(
//                         padding: EdgeInsets.symmetric(vertical: 14.0),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
