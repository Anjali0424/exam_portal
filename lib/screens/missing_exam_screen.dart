import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'missed_exam_screen.dart';

class MissingExamScreen extends StatefulWidget {
  final int studentId;
  final int deptId;

  const MissingExamScreen({
    super.key,
    required this.studentId,
    required this.deptId,
  });

  @override
  State<MissingExamScreen> createState() => _MissingExamScreenState();
}

class _MissingExamScreenState extends State<MissingExamScreen> {
  final supabase = Supabase.instance.client;
  List exams = [];

  @override
  void initState() {
    super.initState();
    fetchMissingExams();
  }

  Future<void> fetchMissingExams() async {
    final now = DateTime.now();

    // 🔥 get all exams of department
    final examData = await supabase
        .from('exams')
        .select()
        .eq('dept_id', widget.deptId);

    // 🔥 get attempted exams
    final attempted = await supabase
        .from('student_exams')
        .select('exam_id')
        .eq('student_id', widget.studentId);

    List attemptedIds =
    attempted.map((e) => e['exam_id']).toList();

    setState(() {
      exams = examData.where((exam) {
        final endTime = DateTime.parse(
            "${exam['exam_date']} ${exam['end_time']}");

        return now.isAfter(endTime) &&
            !attemptedIds.contains(exam['exam_id']);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return exams.isEmpty
        ? Center(child: Text("No Missed Exams 🎉"))
        : ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: exams.length,
      itemBuilder: (context, index) {

        final exam = exams[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MissedExamScreen(
                  subject: exam['subject'],
                ),
              ),
            );
          },

          child: Container(
            margin: EdgeInsets.only(bottom: 14),
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      exam['subject'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),

                    Text(
                      "Missed",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),

                SizedBox(height: 8),

                Text("Date: ${exam['exam_date']}"),
                Text("Time: ${exam['start_time']} - ${exam['end_time']}"),
              ],
            ),
          ),
        );
      },
    );
  }
}