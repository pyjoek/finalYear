import 'package:finalyear/login copy.dart';
import 'package:flutter/material.dart';
import 'package:finalyear/register.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override 
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  @override 
  MyHomeState createState() => MyHomeState();
}

class MyHomeState extends State<MyHome> {
  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Column for centering "Zanzibar University" and the logo
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,  // Center content vertically
              children: [
                // Text at the top - "Zanzibar University"
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),  // Space between text and image
                  child: Text(
                    'Zanzibar University',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                // Centered Logo Image with reduced size
                Padding(
                  padding: const EdgeInsets.only(bottom: 30.0), // Space between image and buttons
                  child: Center(
                    child: SizedBox(
                      width: 250,  // Adjust the width to scale down the image
                      height: 250, // Adjust the height to scale down the image
                      child: Image.asset(
                        'asset/image.png',  // Path to your logo image
                        fit: BoxFit.contain,   // Ensures the image scales within its container
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Spacer pushes the buttons to the bottom
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Login",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Register()));
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
        ],
      ),
    );
  }
}