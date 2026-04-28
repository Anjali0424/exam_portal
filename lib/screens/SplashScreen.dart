import 'dart:async';
import 'package:exam_portal/screens/role_selection_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    // Delay for 1.5 seconds
    Timer(Duration(milliseconds: 2500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RoleSelectionScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          // Top Image
          Image.asset(
            'assets/images/vit_logo.png',
            height: 150,
          ),

          SizedBox(height: 20),

          // App Name
          Text(
            "Exam Portal",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF034EA1),
            ),
          ),

          SizedBox(height: 40),

          // Loading Indicator
          CircularProgressIndicator(
            color: Color(0xFF034EA1),
          ),
        ],
      ),
    );
  }
}

// Temporary Home Screen (next screen)
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Center(child: Text("Next Screen 🚀")),
    );
  }
}