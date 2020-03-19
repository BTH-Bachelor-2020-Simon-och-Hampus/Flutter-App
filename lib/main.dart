import 'package:flutter/material.dart';
import 'package:bachelor_app/views/StartScreen.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Bachelor",
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: StartScreen(),
    );
  }
}