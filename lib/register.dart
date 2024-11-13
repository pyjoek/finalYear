import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  @override 
  register createState() => register();
}

class register extends State<Register> {
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
          child: Text("register"),
        ),
      ),
    );
  }
}