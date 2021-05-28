import 'package:calendar_application/models/event_list.dart';
import 'package:calendar_application/screens/calendar.dart';
import 'package:calendar_application/screens/event_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EventListModel(),
      child: MaterialApp(
        title: 'Flutter Demo',
        darkTheme: ThemeData(
          backgroundColor: Colors.black,
          primarySwatch: Colors.blue,
        ),
        theme: ThemeData(
          backgroundColor: Colors.black,
          primarySwatch: Colors.blue,
        ),
        home: CalendarPage(),
      ),
    );
  }
}
