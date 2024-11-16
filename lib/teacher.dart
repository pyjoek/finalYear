import 'package:flutter/material.dart';

class TeacherPage extends StatefulWidget {
  @override
  Tr createState() => Tr();
}

class Tr extends State<TeacherPage> {
  @override 
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text('Teacher Page'),
        ),
      ),
    );
  }
}