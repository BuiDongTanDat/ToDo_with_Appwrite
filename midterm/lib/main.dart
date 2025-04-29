import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:midterm/bloc/todo_bloc.dart';
import 'package:midterm/bloc/todo_event.dart';
import 'package:midterm/screen/HomePage.dart';
import 'package:midterm/screen/IntroPage.dart';
import 'package:midterm/screen/Login.dart';
import 'package:midterm/screen/Register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> initializeTimezone() async {
  tz.initializeTimeZones();
}

Future<Widget> determineInitialPage() async {
  final prefs = await SharedPreferences.getInstance();

  // Kiểm tra xem có phải lần đầu mở app không
  bool isFirst = prefs.getBool('isFirstLaunch') ?? true;
  if (isFirst) {
    await prefs.setBool('isFirstLaunch', false);
    return const IntroPage();
  }

  // Nếu không phải lần đầu thì kiểm tra phiên đăng nhập
  final sessionId = prefs.getString('session_id');
  final userEmail = prefs.getString('user_email');
  if (sessionId != null && userEmail != null) {
    return HomePage(userName: 'User'); // Có thể cập nhật userName nếu cần
  }

  return const LoginPage();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeTimezone();
  final initialPage = await determineInitialPage();

  runApp(
    BlocProvider(
      create: (context) => TodoBloc()..add(LoadTodos()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: initialPage,
        routes: {
          '/intro': (context) => const IntroPage(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const HomePage(userName: 'User'), //Tên sẽ được thay thế ở HomePage khi đọc dữ liệu
        },
      ),
    ),
  );
}
