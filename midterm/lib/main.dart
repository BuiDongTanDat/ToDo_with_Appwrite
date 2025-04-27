import 'package:flutter/material.dart';
import 'package:midterm/views/AddToDoPage.dart';
import 'package:midterm/views/Login.dart';
import 'package:midterm/views/Register.dart';
import 'package:midterm/views/VerificationPage.dart';

import 'views/HomePage.dart';

void main() {
  runApp(MaterialApp(
    routes: {
      '/': (context) => const HomePage(),
      '/verify': (context) => const VerifyPage(),
    },
    debugShowCheckedModeBanner: false,
    theme: ThemeData(),
    home: LoginPage(),
  ));
}
