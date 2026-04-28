import 'package:exam_portal/screens/start_exam_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AssignedExamScreen extends StatefulWidget {
  final int deptId;
  final int studentId;

  const AssignedExamScreen({
    super.key,
    required this.deptId,
    required this.studentId,
  });

  @override
  State<AssignedExamScreen> createState() => _AssignedExamScreenState();
}

class _AssignedExamScreenState extends State<AssignedExamScreen> {

  final supabase = Supabase.instance.client;
  List exams = [];

  @override
  void initState() {
    super.initState();
    fetchAssignedExams();
  }

  Future<void> fetchAssignedExams() async {
    try {
      final data = await supabase
          .from('exams')
          .select('*, departments(dept_name)')
          .eq('dept_id', widget.deptId)
          .order('exam_date', ascending: true);

      final attempted = await supabase
          .from('student_exams')
          .select('exam_id')
          .eq('student_id', widget.studentId);

      List<String> attemptedIds =
      attempted.map((e) => e['exam_id'].toString()).toList();

      setState(() {
        exams = data.where((exam) {

          final end = DateTime.parse(
            "${exam['exam_date']}T${exam['end_time']}",
          );

          final now = DateTime.now();

          return now.isBefore(end) &&
              !attemptedIds.contains(
                  exam['exam_id'].toString()); // ✅ FIX
        }).toList();
      });

    } catch (e) {
      debugPrint("Error: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    return exams.isEmpty
        ? const Center(child: Text("No Assigned Exams"))
        : ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exams.length,
      itemBuilder: (context, index) {
        final exam = exams[index];

        final now = DateTime.now();

        final start = DateTime.parse(
          "${exam['exam_date']}T${exam['start_time']}",
        );

        final end = DateTime.parse(
          "${exam['exam_date']}T${exam['end_time']}",
        );

        bool isUpcoming = now.isBefore(start);
        bool isOngoing = now.isAfter(start) && now.isBefore(end);
        bool isCompleted = now.isAfter(end);

        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Subject
              Text(
                exam['subject'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF034EA1),
                ),
              ),

              const SizedBox(height: 8),

              // Date
              Text("Date: ${exam['exam_date']}"),

              // Time
              Text("Time: ${exam['start_time']} - ${exam['end_time']}"),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: isOngoing
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StartExamScreen(
                        examId: exam['exam_id'],
                          studentId: widget.studentId, // ⚠️ replace with actual studentId
                      ),
                    ),
                  );
                }
                    : null,

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  isOngoing ? const Color(0xFF034EA1) : Colors.grey,
                ),

                child: Text(
                  isUpcoming
                      ? "Not Started"
                      : isOngoing
                      ? "Start Exam"
                      : "Expired",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}