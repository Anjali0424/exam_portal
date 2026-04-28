import 'package:exam_portal/screens/completed_exam_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:exam_portal/screens/exam_detail_screen.dart';

class CompletedExamScreen extends StatefulWidget {
  const CompletedExamScreen({super.key});

  @override
  State<CompletedExamScreen> createState() => _CompletedExamScreenState();
}

class _CompletedExamScreenState extends State<CompletedExamScreen> {
  final supabase = Supabase.instance.client;
  List exams = [];

  @override
  void initState() {
    super.initState();
    fetchCompletedExams();
  }

  Future<void> fetchCompletedExams() async {
    final now = TimeOfDay.now();

    final data = await supabase.from('exams').select();

    setState(() {
      exams = data.where((exam) {
        final end = exam['end_time'];

        final parts = end.split(':');

        final endTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );

        int nowMin = now.hour * 60 + now.minute;
        int endMin = endTime.hour * 60 + endTime.minute;

        return nowMin > endMin; // ✅ ONLY COMPLETED
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: const Color(0xFF034EA1),
        elevation: 0,
        title: const Text(
          "Completed Exams",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),

      body: exams.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                size: 80, color: Colors.grey[400]),
            const SizedBox(height: 10),
            Text(
              "No Completed Exams",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: exams.length,
        itemBuilder: (context, index) {
          final exam = exams[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExamDetailScreen(
                    examId: exam['exam_id'],
                    subject: exam['subject'],
                  ),
                ),
              );
            },

            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // 🔵 SUBJECT + STATUS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        exam['subject'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF034EA1),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Completed",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 📅 DATE
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        exam['exam_date'],
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey[700]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // ⏰ TIME
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        "${exam['start_time']} - ${exam['end_time']}",
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey[700]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  const Divider(height: 1),

                  const SizedBox(height: 8),

                  // 📊 MARKS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Marks",
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey[600]),
                      ),
                      Text(
                        "${exam['total_marks']}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF034EA1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}