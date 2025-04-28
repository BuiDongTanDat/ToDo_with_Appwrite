import 'package:flutter/material.dart';
import 'package:midterm/views/AddToDoPage.dart';
import 'package:midterm/views/Login.dart';
import 'package:midterm/views/Register.dart';

import 'views/HomePage.dart';

void main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(),
    home: RegisterPage(),
  ));
}
