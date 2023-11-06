import 'package:farmmon_flutter/viewmodel/kakao_login.dart';
import 'package:farmmon_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:farmmon_flutter/viewmodel/main_view_model.dart';
import 'package:farmmon_flutter/view/homepage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // bool _isLogined = false;
  bool _isLoggedin = viewModel.isLoggedin;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(resizeToAvoidBottomInset: false, body: LoginPage()));

    // Scaffold(body: _isLoggedin ? MyApp() : LoginPage())); // MyApp()
  }
}
