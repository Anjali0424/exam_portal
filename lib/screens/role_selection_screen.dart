import 'package:exam_portal/screens/admin_login_screen.dart';
import 'package:exam_portal/screens/student_login_screen.dart';
import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // Title
            Text(
              "Select Your Role",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF034EA1),
              ),
            ),

            SizedBox(height: 40),

            // Student Card
            roleCard(
              icon: Icons.school,
              title: "Student",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentLoginScreen(),
                  ),
                );
              },
            ),

            SizedBox(height: 20),

            // Admin Card
            roleCard(
              icon: Icons.admin_panel_settings,
              title: "Admin",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminLoginScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Reusable Card Widget
  Widget roleCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Color(0xFF034EA1), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Color(0xFF034EA1)),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF034EA1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}