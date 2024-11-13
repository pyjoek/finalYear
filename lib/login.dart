import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  @override 
  login createState() => login();
}

class login extends State<Login> {
  @override 
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: InkWell(
            onTap: () => {
              Navigator.pop(context)
            },
            child: Icon(Icons.arrow_left_sharp,),
          ),
        ),
        body: Center(
          child: Text("login"),
        ),
      ),
    );
  }
}