import 'package:flutter/material.dart';

class MissedExamScreen extends StatelessWidget {
  final String subject;

  const MissedExamScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: Color(0xFF034EA1),
        title: Text(subject),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(Icons.cancel, size: 80, color: Colors.red),

            SizedBox(height: 20),

            Text(
              "You missed this exam",
              style: TextStyle(
                fontSize: 18,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}