import 'package:flutter/material.dart';
import 'package:school_erp/pages/dashboard.dart';
import 'package:school_erp/pages/home.dart';
import 'package:school_erp/pages/chat.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(title: 'School ERP by SHAMIIT'),
        '/home': (context) => Dashboard(),
        '/chat': (context) => ChatActivity(),
      },
      title: 'School ERP by SHAMIIT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
