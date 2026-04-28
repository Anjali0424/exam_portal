import 'package:exam_portal/screens/assigned_exam_screen.dart';
import 'package:exam_portal/screens/completed_exam_screen_student.dart';
import 'package:exam_portal/screens/missing_exam_screen.dart';
import 'package:flutter/material.dart';

class StudentDashboardScreen extends StatelessWidget {
  final String name;
  final int deptId;
  final int studentId;

  const StudentDashboardScreen({super.key,
    required this.name,
    required this.deptId,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // three screens
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Color(0xFF034EA1),
          foregroundColor: Colors.white,
          title: const Text(
            "Student Dashboard",
            style: TextStyle(color: Colors.white), // ← title white
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white, // ← selected tab text
            unselectedLabelColor: Colors.white70, // ← unselected
            tabs: [
              Tab(text: "Assigned"),
              Tab(text: "Completed"),
              Tab(text: "Missing"),
            ],
          ),
        ),

        body: TabBarView(
          children: [
            AssignedExamScreen(deptId: deptId, studentId: studentId),

            CompletedExamScreenStudent(
              studentId: studentId,
            ),

            MissingExamScreen(
              deptId: deptId,
              studentId: studentId,
            ),
          ],
        ),      ),
    );
  }
}