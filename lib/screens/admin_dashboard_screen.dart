import 'package:exam_portal/screens/add_exam_screen.dart';
import 'package:exam_portal/screens/completed_exam_screen.dart';
import 'package:exam_portal/screens/scheduled_exams_screen.dart';
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  final String name;

  const AdminDashboardScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: Text("Admin Dashboard"),
        backgroundColor: Color(0xFF034EA1),
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [

            dashboardCard(
              context,
              "Create Exam",
              Icons.add_circle,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddExamScreen(),
                      ),
                    );
              },
            ),

            dashboardCard(
              context,
              "Scheduled Exams",
              Icons.schedule,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScheduledExamsScreen(),
                      ),
                    );
              },
            ),

            dashboardCard(
              context,
              "Completed Exams",
              Icons.check_circle,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CompletedExamScreen(),
                      ),
                    );
              },
            ),

            dashboardCard(
              context,
              "Results",
              Icons.bar_chart,
                  () {
                // TODO
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget dashboardCard(
      BuildContext context,
      String title,
      IconData icon,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Color(0xFF034EA1).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 35,
                color: Color(0xFF034EA1),
              ),
            ),

            SizedBox(height: 15),

            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}