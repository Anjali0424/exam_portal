import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/mongo_service.dart';

class StudentProfileScreen extends StatefulWidget {

  final int studentId;

  const StudentProfileScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<StudentProfileScreen> createState() =>
      _StudentProfileScreenState();
}

class _StudentProfileScreenState
    extends State<StudentProfileScreen> {

  final supabase = Supabase.instance.client;

  Map<String, dynamic>? studentData;

  Uint8List? profileImageBytes;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadStudentProfile();
  }

  // =========================================================
  // LOAD COMPLETE PROFILE
  // =========================================================

  Future<void> loadStudentProfile() async {

    try {

      // =====================================================
      // FETCH SQL DATA
      // =====================================================

      final sqlData = await supabase
          .from('students')
          .select('''
            student_id,
            name,
            email,
            roll_no,
            departments (
              dept_name
            )
          ''')
          .eq('student_id', widget.studentId)
          .single();

      // =====================================================
      // FETCH MONGODB PROFILE
      // =====================================================

      final mongoProfile =
      await MongoService.getStudentProfile(
        widget.studentId.toString(),
      );

      // =====================================================
      // FETCH PROFILE IMAGE
      // =====================================================

      if (mongoProfile != null &&
          mongoProfile['photoFileId'] != null) {

        String rawFileId =
        mongoProfile['photoFileId'];

        String cleanFileId = rawFileId
            .replaceAll('ObjectId("', '')
            .replaceAll('")', '');

        final imageBytes =
        await MongoService.getImageFromGridFS(
          cleanFileId,
        );

        if (imageBytes != null) {

          profileImageBytes =
              Uint8List.fromList(imageBytes);
        }
      }

      setState(() {
        studentData = sqlData;
        isLoading = false;
      });

    } catch (e) {

      print("Profile Error: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF034EA1),

        title: const Text(
          "Student Profile",

          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        foregroundColor: Colors.white,
      ),

      body: isLoading

          ? const Center(
        child: CircularProgressIndicator(),
      )

          : studentData == null

          ? const Center(
        child: Text("Profile not found"),
      )

          : SingleChildScrollView(

        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(

            children: [

              // ===================================================
              // PROFILE CARD
              // ===================================================

              Container(
                width: double.infinity,

                padding: const EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 20,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                  BorderRadius.circular(24),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(

                  children: [

                    // ===============================================
                    // PROFILE IMAGE
                    // ===============================================

                    CircleAvatar(
                      radius: 60,

                      backgroundColor:
                      Colors.grey.shade200,

                      backgroundImage:
                      profileImageBytes != null
                          ? MemoryImage(
                        profileImageBytes!,
                      )
                          : null,

                      child: profileImageBytes == null
                          ? const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey,
                      )
                          : null,
                    ),

                    const SizedBox(height: 20),

                    // ===============================================
                    // NAME
                    // ===============================================

                    Text(
                      studentData!['name'] ?? "",

                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF034EA1),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      studentData!['email'] ?? "",

                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 25),

                    Divider(),

                    const SizedBox(height: 15),

                    // ===============================================
                    // DETAILS
                    // ===============================================

                    profileTile(
                      icon: Icons.badge,
                      title: "Student ID",
                      value:
                      studentData!['student_id']
                          .toString(),
                    ),

                    profileTile(
                      icon: Icons.confirmation_number,
                      title: "Roll Number",
                      value:
                      studentData!['roll_no']
                          .toString(),
                    ),

                    profileTile(
                      icon: Icons.school,
                      title: "Department",
                      value:
                      studentData!['departments']
                      ['dept_name']
                          .toString(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ===================================================
              // EXTRA SECTION
              // ===================================================

              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                  BorderRadius.circular(20),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    const Text(
                      "Account Status",

                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF034EA1),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [

                        Container(
                          height: 12,
                          width: 12,

                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),

                        const SizedBox(width: 10),

                        const Text(
                          "Profile Active",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // PROFILE TILE
  // =========================================================

  Widget profileTile({
    required IconData icon,
    required String title,
    required String value,
  }) {

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 18,
      ),

      child: Row(

        children: [

          Container(
            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color:
              const Color(0xFF034EA1)
                  .withOpacity(0.1),

              borderRadius:
              BorderRadius.circular(12),
            ),

            child: Icon(
              icon,
              color: const Color(0xFF034EA1),
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  title,

                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}