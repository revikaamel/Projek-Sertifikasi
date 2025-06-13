import 'package:flutter/material.dart';
import 'package:uji/screens/login_screen.dart';
import 'package:uji/screens/main_screen.dart';
import 'package:uji/screens/admin_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toko Roti & Kue Online',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainScreen(),
        '/admin': (context) => const AdminScreen(),

      },
    );
  }
}