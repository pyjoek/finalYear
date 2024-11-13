import 'package:flutter/material.dart';
import 'package:baraka/login.dart';
import 'package:baraka/register.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override 
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  @override 
  Myhome createState() => Myhome();
}

class Myhome extends State<MyHome> {

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          children: [
            InkWell(
              onTap: () => {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Login())),
              },
              child: Text("login"),
            ),
             InkWell(
              onTap: () => {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Register())),
              },
              child: Text("register"),
            )
          ],
        ),
      ),
    );
  }
} 