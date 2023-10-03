import 'package:farmmon_flutter/main.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLogined = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(body: _isLogined ? MyApp() : LoginPage()));
  }
}
