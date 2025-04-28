import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:midterm/bloc/todo_bloc.dart';
import 'package:midterm/bloc/todo_event.dart';
import 'package:midterm/screen/HomePage.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'service/permission_service.dart';

Future<void> initializeTimezone() async {
  tz.initializeTimeZones();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestExactAlarmPermission();
  await initializeTimezone();

  runApp(
    BlocProvider(
      create: (context) => TodoBloc()..add(LoadTodos()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomePage(),
      ),
    ),
  );
}
