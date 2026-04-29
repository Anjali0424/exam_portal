import 'dart:typed_data';

import 'package:exam_portal/screens/assigned_exam_screen.dart';
import 'package:exam_portal/screens/completed_exam_screen_student.dart';
import 'package:exam_portal/screens/missing_exam_screen.dart';
import 'package:exam_portal/services/mongo_service.dart';
import 'package:exam_portal/screens/student_profile_screen.dart';


import 'package:flutter/material.dart';

class StudentDashboardScreen extends StatefulWidget {

  final String name;
  final int deptId;
  final int studentId;

  const StudentDashboardScreen({
    super.key,
    required this.name,
    required this.deptId,
    required this.studentId,
  });

  @override
  State<StudentDashboardScreen> createState() =>
      _StudentDashboardScreenState();
}

class _StudentDashboardScreenState
    extends State<StudentDashboardScreen> {

  Uint8List? profileImageBytes;

  @override
  void initState() {
    super.initState();

    loadProfileImage();
  }

  // =========================================================
  // LOAD PROFILE IMAGE FROM MONGODB GRIDFS
  // =========================================================

  Future<void> loadProfileImage() async {

    try {

      final studentProfile =
      await MongoService.getStudentProfile(
        widget.studentId.toString(),
      );

      if (studentProfile != null &&
          studentProfile['photoFileId'] != null) {

        final imageBytes =
        await MongoService.getImageFromGridFS(
          studentProfile['photoFileId'],
        );

        if (imageBytes != null) {

          setState(() {
            profileImageBytes =
                Uint8List.fromList(imageBytes);
          });
        }
      }

    } catch (e) {

      print("Profile Image Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 3,

      child: Scaffold(
        backgroundColor: Colors.grey[100],

        appBar: AppBar(
          backgroundColor: const Color(0xFF034EA1),

          foregroundColor: Colors.white,

          title: const Text(
            "Student Dashboard",

            style: TextStyle(
              color: Colors.white,
            ),
          ),

          // ===================================================
          // PROFILE AVATAR
          // ===================================================

          actions: [

            GestureDetector(

              onTap: () {

                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (context) => StudentProfileScreen(
                      studentId: widget.studentId,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 14,
                ),

                child: CircleAvatar(
                  radius: 20,

                  backgroundColor: Colors.white,

                  backgroundImage:
                  profileImageBytes != null
                      ? MemoryImage(profileImageBytes!)
                      : null,

                  child: profileImageBytes == null
                      ? const Icon(
                    Icons.person,
                    color: Color(0xFF034EA1),
                  )
                      : null,
                ),
              ),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,

            labelColor: Colors.white,

            unselectedLabelColor:
            Colors.white70,

            tabs: [

              Tab(text: "Assigned"),

              Tab(text: "Completed"),

              Tab(text: "Missing"),
            ],
          ),
        ),

        body: TabBarView(
          children: [

            AssignedExamScreen(
              deptId: widget.deptId,
              studentId: widget.studentId,
            ),

            CompletedExamScreenStudent(
              studentId: widget.studentId,
            ),

            MissingExamScreen(
              deptId: widget.deptId,
              studentId: widget.studentId,
            ),
          ],
        ),
      ),
    );
  }
}