// import 'package:baraka/student.dart';
// import 'package:flutter/material.dart';

// class Login extends StatefulWidget {
//   @override
//   _LoginState createState() => _LoginState();
// }

// class _LoginState extends State<Login> {
//   late double height, width;
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

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
//             // Login Form Container
//             Positioned(
//               left: width * 0.1,
//               right: width * 0.1,
//               bottom: height * 0.3,
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
//                     // Email TextField
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
//                     // Password TextField
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
//                     // Login Button
//                     ElevatedButton(
//                       onPressed: () {
//                         // Login button pressed
//                       },
//                       style: ElevatedButton.styleFrom(
//                         padding: EdgeInsets.symmetric(vertical: 14.0),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       child: InkWell(
//                         onTap: () => {
//                           Navigator.push(context, MaterialPageRoute(builder: (context) => StudentPage()))
//                         },
//                         child: Text(
//                         "Login",
//                         style: TextStyle(fontSize: 18),
//                       ),
//                       )
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
